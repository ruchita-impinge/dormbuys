require "net/ftp"

class ThirdPartySystems
  
  
  def self.generate_initial_lnt_file
    fields = [
    "Product Code",
    "Is the Product Code Unique?",
    "SKU",
    "Is the SKU Unique?",
    "Barcode",
    "Product Availability",
    "Product Parent Name",
    "Product Parent Description",
    "Parent Description Bullet Point 1",
    "Parent Description Bullet Point 2",
    "Parent Description Bullet Point 3",
    "Parent Description Bullet Point 4",
    "Parent Description Bullet Point 5",
    "Product Child Name",
    "Has a Parent?",
    "Product Child Description",
    "Child Description Bullet Point 1",
    "Child Description Bullet Point 2",
    "Child Description Bullet Point 3",
    "Child Description Bullet Point 4",
    "Child Description Bullet Point 5",
    "Brand Name",
    "Category Name",
    "Product Type",
    "Product Size",
    "Product Color",
    "Product Quantity",
    "Product Retail Price",
    "Product Comparison Price",
    "Additional Charge",
    "Additional Charge Description",
    "Product Parent Image URL",
    "Product Child Image URL"]
    
  end #end method self.generate_initial_lnt_file
  
  
  # Google Products updater.  This method creates and writes a tab-delimited
  # file of product information.  Then using FTP it uploads the file to google
  #
  #--------------------------------------------------
  #add the a cron to one webserver to run this script
  #
  # run every day at 2am
  # 0 2 * * * cd /{path_to_app} && ruby script/runner -e production ThirdPartySystems.update_google_products
  #
  # run every 4 hours
  # 0 */4 * * * cd /{path_to_app} && ruby script/runner -e production ThirdPartySystems.update_google_products
  #--------------------------------------------------
  def self.update_google_products
    
    #headings for tab delimited file
    output = "id\tlink\ttitle\tdescription\timage_link\tprice\tcondition\n"
    
    #fetch all the products to put into the file
    @product_variations = ProductVariation.find(:all, :conditions => {:visible => true})
    
    #loop through products and add to file
    for variation in @product_variations
      
      #setup vars
      id = variation.product_number
      link = "http://www.dormbuys.com/shop/product/" + "#{variation.product.id}"
      title = variation.full_title[0,80]
      
      description = variation.product.product_overview.gsub(/(\r\n|\r|\n|\t)/s, "")
      #description.gsub!(/”/, "&quote;")
      #description.gsub!(/"/, "&quote;")
      #description.gsub!(/'/, "&rsquo;")
      #title.gsub!(/”/, "&quote;")
      #title.gsub!(/"/, "&quote;")
      #title.gsub!(/'/, "&rsquo;")
      
      begin
        img_lnk = "http://www.dormbuys.com" + variation.product.main_image
      rescue
        img_lnk = "http://www.dormbuys.com"
      end
      
      price = variation.current_price
      condition = "new"
      
      #add the line to the output
      output += "#{id}\t#{link}\t#{title}\t#{description}\t#{img_lnk}\t#{price}\t#{condition}\n"
      
    end #end for loop
    
    
    #transfer to FTP
    self.ftp_transfer_content(
      output, 
      "google_products.txt", 
      APP_CONFIG['googleproducts']['host'], 
      APP_CONFIG['googleproducts']['user'], 
      APP_CONFIG['googleproducts']['pass'])
    
  end #end method self.update_google_products
  
  
  
  def self.latest_db_blog
    require 'rss/1.0'
    require 'rss/2.0'
    require 'open-uri'

    source = "http://blog.dormbuys.com/?feed=rss2" # url or local file
    content = "" # raw content of rss feed will be loaded here
    open(source) do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)
    
    recent = rss.items[0]
    
    latest_scrape = BlogScrape.find(:first, :order => 'created_at DESC')
    unless latest_scrape
      BlogScrape.create(
        :title => recent.title,
        :description => recent.description,
        :link => recent.link)
    else
      if recent.date > latest_scrape.created_at
        BlogScrape.create(
          :title => recent.title,
          :description => recent.description,
          :link => recent.link)
      end
    end
    
  end #end method self.latest_db_blog
  
  
  # run every day at 3am
  # 0 3 * * * cd /{path_to_app} && ruby script/runner -e production ThirdPartySystems.update_channel_advisor
  def self.update_channel_advisor
    
    #headings for pipe delimited file
    output = "Model|Manufacturer|ManufacturerModel|MPN|MerchantCategory|Brand|CurrentPrice|InStock|ReferenceImageURL|OfferName|OfferDescription|ActionURL\n"
    
    #fetch all the products to put into the file
    @product_variations = ProductVariation.find(:all, :conditions => {:visible => true})
    
    #loop through products and add to file
    for variation in @product_variations
      
      #setup vars
      _model = variation.product_number
      _manufacturer = "" #variation.product.vendor.company_name rescue "Dormbuys.com"
      _manufacturer_model = variation.manufacturer_number.blank? ? "0" : variation.manufacturer_number
      _MPN = variation.manufacturer_number.blank? ? "0" : variation.manufacturer_number
      _merchant_category = variation.subcategory
      _brand = "" #variation.product.vendor.company_name rescue "Dormbuys.com"
      _current_price = variation.current_price.to_s
      _in_stock = variation.qty_on_hand > 0 ? 1 : 0
      begin
        _reference_image_url = "http://www.dormbuys.com" + variation.product.main_image
      rescue
        _reference_image_url = "http://www.dormbuys.com/images/home_2_0/logo.gif"
      end
      
      _offer_name = variation.full_title.gsub("|", "-")
      _offer_description = variation.product.product_overview.gsub(/(\r\n|\r|\n|\t)/s, "").gsub("|","-")
      _action_url = "http://www.dormbuys.com/shop/product/" + "#{variation.product.id}"
      

      #add the line to the output
      output += "#{_model}|#{_manufacturer}|#{_manufacturer_model}|#{_MPN}|#{_merchant_category}|#{_brand}|#{_current_price}|#{_in_stock}|#{_reference_image_url}|#{_offer_name}|#{_offer_description}|#{_action_url}\n"
      
    end #end for loop
    
    
    #transfer to FTP
    self.ftp_transfer_content(
      output, 
      "channel_advisor.txt", 
      APP_CONFIG['channel_advisor']['host'], 
      APP_CONFIG['channel_advisor']['user'], 
      APP_CONFIG['channel_advisor']['pass'])
    
    
  end #end method self.update_channel_advisor
  
  
  
  
  
  def self.update_packstream
    
    @products = Product.find(:all)
    
    xml = %(<?xml version="1.0" encoding="UTF-8"?>\n)
    xml += %(<products>)
    
    for p in @products
      xml += %(<product>)
      xml += %(<product_id>#{p.id}</product_id>\n)
      xml += %(<product_name>#{CGI::escapeHTML(p.product_name)}</product_name>)
      xml += %(<product_overview>#{CGI::escapeHTML(p.product_overview)}</product_overview>)
      pimage = p.main_image rescue ""
      xml += %(<image_url><![CDATA[http://www.dormbuys.com#{pimage}]]></image_url>)
      xml += %(<price>#{p.our_price}</price>)
      xml += %(<msrp>#{p.list_price}</msrp>)
      xml += %(<url><![CDATA[http://www.dormbuys.com/shop/product/#{p.id}]]></url>)
      xml += %(<visible>#{p.visible}</visible>)
      
      xml += %(<recommendations>)
      for r in p.cross_sell_products
        xml += %(<product_id>#{r.id}</product_id>\n)
        xml += %(<product_name>#{CGI::escapeHTML(r.product_name)}</product_name>)
        xml += %(<product_overview>#{CGI::escapeHTML(r.product_overview)}</product_overview>)
        rimage = r.main_image rescue ""
        xml += %(<image_url><![CDATA[http://www.dormbuys.com#{rimage}]]></image_url>)
        xml += %(<price>#{r.our_price}</price>)
        xml += %(<msrp>#{r.list_price}</msrp>)
        xml += %(<url><![CDATA[http://www.dormbuys.com/shop/product/#{r.id}]]></url>)
        xml += %(<visible>#{r.visible}</visible>)
      end
      xml += %(</recommendations>)
      
      xml += %(<variations>)
        for v in p.product_variations
          xml += %(<product_number>#{v.product_number}</product_number>)
          xml += %(<title>#{CGI::escapeHTML(v.title)}</title>)
          xml += %(<full_title>#{CGI::escapeHTML(v.full_title)}</full_title>)
          xml += %(<qty_on_hand>#{v.qty_on_hand}</qty_on_hand>)
          xml += %(<qty_on_hold>#{v.qty_on_hold}</qty_on_hold>)
          xml += %(<msrp>#{v.retail_price}</msrp>)
          xml += %(<price>#{v.current_price}</price>)
          xml += %(<visible>#{v.visible}</visible>)
        end
      xml += %(</variations>)
      xml += %(</product>)
    end #end for loop
    
    xml += %(</products>)
    
    
    ftp_file = "#{RAILS_ROOT}/public/files/products/packstream_products.xml"
    fh = File.new(ftp_file, "w")
    fh.puts(xml)
    fh.close
  
  end #end method self.update_packstream
    
    
  
  
  
  
  
  def self.ftp_transfer_content(content, file_name, ftp_host, ftp_user, ftp_pass)
    
    #write out the output file and save to "ftp_file"
    ftp_file = file_name
    fh = File.new(ftp_file, "w")
    fh.puts(content)
    fh.close
    
    #setup ftp connection
    ftp = Net::FTP.new(ftp_host) 

    #mode settings
    ftp.debug_mode=true
    ftp.passive = true

    #login to FTP server
    ftp.login(user = ftp_user, passwd = ftp_pass)

    #get the size of the file we are sending
    filesize = Float(File.size(ftp_file))

    #init the transfered size
    r_size = 0

    #do the file transfer
    ftp.putbinaryfile(ftp_file, File.basename(ftp_file)) do |data|

        #update the size that has been transfered
        r_size += data.size

        #convert transfered to a percentage
        percent = (r_size/filesize)*100

        #print how much has been transfered
        printf("Transfered : %i \r", percent)
        
        #flush the console screen
        $stdout.flush

    end #end putbinaryfile

    #show file listing of ftp dir
    print ftp.list('all')

    #clost the FTP connection
    ftp.close
    
  end #end method self.ftp_transfer_content()
  
  
  

end #end class