require "net/ftp"
require 'net/https'
require 'open-uri'
require "iconv"

class ThirdPartySystems
    
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
    @product_variations = ProductVariation.find(:all, :conditions => {:visible => true}, :include => [:product])
    
    #loop through products and add to file
    for variation in @product_variations
      if variation.product
        #setup vars
        id = variation.product_number
        link = "http://dormbuys.com" + "#{variation.product.default_front_url}"
        title = variation.full_title[0,80]
      
        description = variation.product.product_overview.gsub(/(\r\n|\r|\n|\t)/s, "")
        #description.gsub!(/”/, "&quote;")
        #description.gsub!(/"/, "&quote;")
        #description.gsub!(/'/, "&rsquo;")
        #title.gsub!(/”/, "&quote;")
        #title.gsub!(/"/, "&quote;")
        #title.gsub!(/'/, "&rsquo;")
      
        begin
          img_lnk = "#{variation.product.product_image.url(:main)}"
        rescue
          img_lnk = "http://www.dormbuys.com"
        end
      
        price = variation.rounded_retail_price.to_s
        condition = "new"
      
        #add the line to the output
        output += "#{id}\t#{link}\t#{title}\t#{description}\t#{img_lnk}\t#{price}\t#{condition}\n"
      end
    end #end for loop
    
    
    #transfer to FTP
    self.ftp_transfer_content(
      output, 
      "google_products.txt", 
      APP_CONFIG['googleproducts']['host'], 
      APP_CONFIG['googleproducts']['user'], 
      APP_CONFIG['googleproducts']['pass'])
    
  end #end method self.update_google_products
  
  
  def self.update_bing_shopping(options={})
    #headings for tab delimited file
    headings = [
      "MPID",                #product_number
      "Title",               #product_name
      "BrandorManufacturer", #brand.name
      "MPN",                 #product_number
      "UPC",                 # ==> Leave blank
      "ISBN",                # ==> Leave blank
      "MerchantSKU",         #product_number
      "ProductURL",          #product page URL
      "Price",               #price with tax and shipping 
      "StockStatus",         # one of: In Stock, Not In Stock
      "Description",         #product_overview
      "ImageURL",            #image url
      "Shipping",            # lowest amnt a customer would pay for shipping the product
      "MerchantCategory",    # merchant category tree separated by dash
      "BingCategory",        # bing category, blank if n/a
      "ShippingWeight",      #shipping weight
      "Condition"            #always new
    ]
    output = "#{headings.join("\t")}\r\n"
    
    #fetch all the products to put into the file
    if options[:test]
      @product_variations = ProductVariation.find(:all, :conditions => {:visible => true}, :include => [:product], :limit => 10)
    else
      @product_variations = ProductVariation.find(:all, :conditions => {:visible => true}, :include => [:product])
    end
    
    #loop through products and add to file
    for variation in @product_variations
      if variation.product
        
        mpid              = variation.product_number
        title             = variation.full_title
        brand             = variation.product.brands.size > 0 ? variation.product.brands.first.name : "Dormbuys.com"
        mpn               = variation.product_number
        upc               = ""
        isbn              = ""
        merchant_sku      = variation.product_number
        product_url       = "http://dormbuys.com#{variation.product.default_front_url}"
        price             = (variation.rounded_retail_price + ShippingRatesTable.get_rate(variation.rounded_retail_price)).to_s
        stock_status      = variation.qty_on_hand > 0 ? "In Stock" : "Out of Stock"
        description       = variation.product.product_overview.gsub(/(\r\n|\r|\n|\t)/s, "")
        image_url         = variation.image? ? variation.image(:main).split("?").first : variation.product.product_image.url(:main).split("?").first
        shipping          = ShippingRatesTable.get_rate(variation.rounded_retail_price).to_s
        
        if variation.product.subcategories.first.blank?
          merchant_category = "Dorm Decor"
        else
          if variation.product.subcategories.first.category.blank?
            merchant_category = variation.product.subcategories.first.name
          else
            merchant_category = "#{variation.product.subcategories.first.category.name} - #{variation.product.subcategories.first.name}"
          end
        end
        bing_category     = ""
        shipping_weight   = variation.product_packages.collect.sum {|pp| pp.weight}
        condition         = "New"
      
        #add the line to the output
        output += "#{mpid}\t#{title}\t#{brand}\t#{mpn}\t#{upc}\t#{isbn}\t#{merchant_sku}\t#{product_url}\t#{price}\t"
        output += "#{stock_status}\t#{description}\t#{image_url}\t#{shipping}\t#{merchant_category}\t#{bing_category}\t"
        output += "#{shipping_weight}\t#{condition}\r\n"
      end
    end #end for loop
    
    
    #fix UTF characters
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    output = ic.iconv(output + ' ')[0..-2]
    
    #transfer to FTP
    self.ftp_transfer_content(
      output, 
      "bingshopping.txt", 
      APP_CONFIG['bingshopping']['host'], 
      APP_CONFIG['bingshopping']['user'], 
      APP_CONFIG['bingshopping']['pass'])
    
  end #end method self.update_bing_shopping
  
  
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
      _merchant_category = variation.subcategories.first.name
      _brand = variation.product.brands.empty? ? "" : variation.product.brands.first.name  #variation.product.vendor.company_name rescue "Dormbuys.com"
      _current_price = variation.rounded_retail_price.to_s
      _in_stock = variation.qty_on_hand > 0 ? 1 : 0

      begin
        _reference_image_url = "#{variation.image.file? ? variation.image.url(:main) : variation.product.product_image.url(:main)}"
      rescue
        _reference_image_url = "http://dormbuys.com"
      end
      
      _offer_name = variation.full_title.gsub("|", "-")
      _offer_description = variation.product.product_overview.gsub(/(\r\n|\r|\n|\t)/s, "").gsub("|","-")
      _action_url = "http://dormbuys.com" + #{variation.product.default_front_url}"
      

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
  
  
  
  
  def self.update_lnt
    
    processed_product_ids = []
    
    clean_for_csv = Proc.new do |str|
      str.gsub(/(\r\n|\r|\n|\t)/s, " ").gsub(","," ") #.gsub(/"/,"").gsub(/'/, "")
    end
    
    
    
    hdr = {
      :product_code => "Product Code", #required
      :is_unique => "Is the Product Code Unique?",  #torrey commerce only
      :sku => "SKU",
      :is_sku_unique => "Is the SKU Unique?", #torrey commerce only
      :barcode => "Barcode",
      :product_availability => "Product Availability",
      :product_parent_name => "Product Parent Name", #required
      :product_parent_description => "Product Parent Description",
      :product_bullet_1 => "Product Description Bullet Point 1",
      :product_bullet_2 => "Product Description Bullet Point 2",
      :product_bullet_3 => "Product Description Bullet Point 3",
      :product_bullet_4 => "Product Description Bullet Point 4",
      :product_bullet_5 => "Product Description Bullet Point 5",
      :product_child_name => "Product Child Name", #required
      :has_a_parent => "Has a Parent?", #torrey commerce only
      :product_child_description => "Product Child Description",
      :child_bullet_1 => "Child Description Bullet Point 1",
      :child_bullet_2 => "Child Description Bullet Point 2",
      :child_bullet_3 => "Child Description Bullet Point 3",
      :child_bullet_4 => "Child Description Bullet Point 4",
      :child_bullet_5 => "Child Description Bullet Point 5",
      :brand_name => "Brand Name", #required
      :category_name => "Category Name", #required
      :product_type => "Product Type",
      :product_size => "Product Size",
      :product_color => "Product Color", #required
      :product_quantity => "Product Quantity", #required
      :product_retail_price => "Product Retail Price", #required
      :product_comparison_price => "Product Comparison Price",
      :additional_charge => "Additional Charge",
      :additional_charge_description => "Additional Charge Description",
      :product_parent_image_url => "Product Parent Image URL",
      :product_child_image_url => "Product Child Image URL"
    }
  
    # setup the output headers
    #
    @headings = [] 
    @headings << hdr[:product_code]
    @headings << hdr[:product_parent_name]
    @headings << hdr[:product_parent_description]
    @headings << hdr[:brand_name]
    @headings << hdr[:category_name]
    @headings << hdr[:product_size]
    @headings << "Product Name"
    @headings << "Product Description"
    @headings << "Attribute Name"
    @headings << hdr[:product_quantity]
    @headings << hdr[:product_retail_price]
    @headings << hdr[:product_comparison_price]
    @headings << hdr[:product_parent_image_url]
    
    @rows = []
  
    @variations = ThirdPartySystems.get_lnt_product_variations(:new_only => true)
    
    @variations.each do |variation|
      
      2.times do |i|
      
        row = []
      
        if i == 0
          row << "#{clean_for_csv.call variation.product_number}"
        else
          row << "#{clean_for_csv.call variation.product_number}A"
        end
        
        row << "#{clean_for_csv.call variation.full_title}"
        row << "#{clean_for_csv.call variation.product.product_overview}"
      
      
        #add brand
        if i == 0
          row << "Dormbuys.com"
        else
          row << "SpaceItUp"
        end
      
        #add LNT category
        unless variation.product.subcategories.first.blank?
          lnt_cat_id = variation.product.subcategories.first.third_party_cat(ThirdPartyCategory::LNT)
          if lnt_cat_id
            lnt_cat = ThirdPartyCategory.find(lnt_cat_id)
            row << "#{lnt_cat.name}"
          else
            row << "UNKNOWN"
          end
        
        else
          row << "UNKNOWN"
        end
      
      
      
        #handle product_size
        if variation.title != "default"
        
          if variation.variation_group.downcase =~ /size/
            row << "#{clean_for_csv.call variation.title.split("/").first}"
          else
            row << ""
          end
        
        else
          row << ""
        end #end if-child
      
      
        #handle product name and product description
        row << "#{clean_for_csv.call variation.full_title}"
        row << "#{clean_for_csv.call variation.product.product_overview}"
      
      
        #handle 'attribute name'
        if variation.title != "default"
        
          row << "#{clean_for_csv.call variation.title.split("/").last}"
        
        else
          row << ""
        end #end if-child
      
      
        #product qty
        row << "#{variation.qty_on_hand}"
      
      
        #product price
        row << "#{ThirdPartySystems.get_lnt_price(variation)}"
      
        #handle the comparison price
        row << "#{ThirdPartySystems.get_lnt_comparison_price(variation)}"
      
        #handle product image
        #row << "http://www.dormbuys.com#{variation.product.main_image}"
=begin
        unless processed_product_ids.include? variation.product.id
          processed_product_ids << variation.product.id
        
          #row << variation.product.additional_product_images.collect {|ai| "#{ai.image.url(:main)}"}.join("|")
          pimgs = []
          pimgs << variation.product.product_image(:original).split("?").first
          variation.product.additional_product_images.each {|ai| pimgs << ai.image(:original).split("?").first }
          row << pimgs.join("|")
        end
=end

        if variation.title == "default"
          row << variation.product.product_image(:original).split("?").first
        else
          if variation.image.file?
            row << variation.image(:original).split("?").first
          else
            row << variation.product.product_image(:original).split("?").first
          end
        end
      
        @rows << row
        
      end #end 2.times
      
    end #end each variation
  
  
    file_content = @headings.join(",") + "\n"
    for row in @rows
      file_content += row.join(",") + "\n"
    end
  
  
    ftp_file = "#{RAILS_ROOT}/public/content/integrations/LNT_PRODUCTS.csv"
    FileUtils.mkdir_p(File.dirname(ftp_file))
    fh = File.new(ftp_file, "w")
    fh.puts(file_content)
    fh.close
    
  end #end method self.update_lnt
  
  
  
  def self.update_lnt_generic
    
    processed_product_ids = []
    
    clean_for_csv = Proc.new do |str|
      return "" if str.blank?
      str.gsub(/(\r\n|\r|\n|\t)/s, " ").gsub(","," ") #.gsub(/"/,"").gsub(/'/, "")
    end
    
    
    
    hdr = {
      :product_code => "Product Code", #required
      :is_unique => "Is the Product Code Unique?",  #torrey commerce only
      :sku => "SKU",
      :is_sku_unique => "Is the SKU Unique?", #torrey commerce only
      :barcode => "Barcode",
      :product_availability => "Product Availability",
      :product_parent_name => "Product Parent Name", #required
      :product_parent_description => "Product Parent Description",
      :product_bullet_1 => "Product Description Bullet Point 1",
      :product_bullet_2 => "Product Description Bullet Point 2",
      :product_bullet_3 => "Product Description Bullet Point 3",
      :product_bullet_4 => "Product Description Bullet Point 4",
      :product_bullet_5 => "Product Description Bullet Point 5",
      :product_child_name => "Product Child Name", #required
      :has_a_parent => "Has a Parent?", #torrey commerce only
      :product_child_description => "Product Child Description",
      :child_bullet_1 => "Child Description Bullet Point 1",
      :child_bullet_2 => "Child Description Bullet Point 2",
      :child_bullet_3 => "Child Description Bullet Point 3",
      :child_bullet_4 => "Child Description Bullet Point 4",
      :child_bullet_5 => "Child Description Bullet Point 5",
      :brand_name => "Brand Name", #required
      :category_name => "Category Name", #required
      :product_type => "Product Type",
      :product_size => "Product Size",
      :product_color => "Product Color", #required
      :product_quantity => "Product Quantity", #required
      :product_retail_price => "Product Retail Price", #required
      :product_comparison_price => "Product Comparison Price",
      :additional_charge => "Additional Charge",
      :additional_charge_description => "Additional Charge Description",
      :product_parent_image_url => "Product Parent Image URL",
      :product_child_image_url => "Product Child Image URL"
    }
  
    # setup the output headers
    #
    @headings = [] 
    @headings << hdr[:product_code]
    @headings << hdr[:product_parent_name]
    @headings << hdr[:product_parent_description]
    @headings << hdr[:brand_name]
    @headings << hdr[:category_name]
    @headings << hdr[:product_size]
    @headings << "Product Name"
    @headings << "Product Description"
    @headings << "Attribute Name"
    @headings << hdr[:product_quantity]
    @headings << hdr[:product_retail_price]
    @headings << hdr[:product_comparison_price]
    @headings << hdr[:product_parent_image_url]
    
    @rows = []
  
    @variations = ThirdPartySystems.get_lnt_product_variations(:new_only => false)
    
    @variations.each do |variation|
      
      row = []
      
      row << "#{clean_for_csv.call variation.product_number}A"
      row << "#{clean_for_csv.call variation.full_title}"
      row << "#{variation.product.description_general.blank? ? "" : clean_for_csv.call(variation.product.description_general)}"
      
      
      #add brand
      row << "SpaceItUp"
      
      #add LNT category
      unless variation.product.subcategories.first.blank?
        lnt_cat_id = variation.product.subcategories.first.third_party_cat(ThirdPartyCategory::LNT2)
        if lnt_cat_id
          lnt_cat = ThirdPartyCategory.find(lnt_cat_id)
          row << "#{lnt_cat.name}"
        else
          row << "UNKNOWN"
        end
        
      else
        row << "UNKNOWN"
      end
      
      
      
      #handle product_size
      if variation.title != "default"
        
        if variation.variation_group.downcase =~ /size/
          row << "#{clean_for_csv.call variation.title.split("/").first}"
        else
          row << ""
        end
        
      else
        row << ""
      end #end if-child
      
      
      #handle product name and product description
      row << "#{clean_for_csv.call variation.full_title}"
      row << "#{clean_for_csv.call variation.product.product_overview}"
      
      
      #handle 'attribute name'
      if variation.title != "default"
        
        row << "#{clean_for_csv.call variation.title.split("/").last}"
        
      else
        row << ""
      end #end if-child
      
      
      #product qty
      row << "#{variation.qty_on_hand}"
      
      
      #product price
      row << "#{ThirdPartySystems.get_lnt_price(variation)}"
      
      #handle the comparison price
      row << "#{ThirdPartySystems.get_lnt_comparison_price(variation)}"
      

      #handle product image
      if variation.title == "default"
        row << variation.product.product_image(:original).split("?").first
      else
        if variation.image.file?
          row << variation.image(:original).split("?").first
        else
          row << variation.product.product_image(:original).split("?").first
        end
      end
      
      @rows << row
      
    end #end each variation
  
  
    file_content = @headings.join(",") + "\n"
    for row in @rows
      file_content += row.join(",") + "\n"
    end
  
  
    ftp_file = "#{RAILS_ROOT}/public/content/integrations/LNT_GENERIC_PRODUCTS.csv"
    FileUtils.mkdir_p(File.dirname(ftp_file))
    fh = File.new(ftp_file, "w")
    fh.puts(file_content)
    fh.close
    
  end #end method self.update_lnt_generic
  
  
  
  def self.update_fetchback
    
    @headings = [] 
    @headings << "Product ID"
    @headings << "Product Name"
    @headings << "Product Price"
    @headings << "Product Image URL"
    @headings << "Product Page URL"
    
    @rows = []
    
    @products = Product.find(:all, :conditions => {:visible => true}, :include => [:product_variations])
    
    @products.each do |product|
      if product.available_variations.size > 0
        row = []  
    
        #product id
        row << product.id
    
        #product name
        row << product.product_name.gsub(",","")
    
        #product price
        row << product.retail_price
    
        #product image url
        row << product.product_image(:large)
    
        #product page url
        row << "http://dormbuys.com#{product.default_front_url rescue '/'}"
    
        @rows << row
      end
    end #end each variation
  
  
    file_content = @headings.join(",") + "\n"
    for row in @rows
      file_content += row.join(",") + "\n"
    end
  
  
    ftp_file = "#{RAILS_ROOT}/public/content/integrations/FETCHBACK.csv"
    FileUtils.mkdir_p(File.dirname(ftp_file))
    fh = File.new(ftp_file, "w")
    fh.puts(file_content)
    fh.close
    
  end #end method self.update_fetchback
  
  
  
  
  def self.update_lnt_inventory

    @headings = [] 
    @headings << "Product SKU"
    @headings << "Prices"
    @headings << "Compare Prices"
    @headings << "Quantity"
    
    @rows = []
  
    @variations = ThirdPartySystems.get_lnt_product_variations
    
    @variations.each do |variation|
      
      2.times do |i|
        row = []  
      
        if i == 0
          row << "#{variation.product_number}"
        else
          row << "#{variation.product_number}A"
        end
      
        #product price
        row << "#{ThirdPartySystems.get_lnt_price(variation)}"
      
        #handle the comparison price
        row << "#{ThirdPartySystems.get_lnt_comparison_price(variation)}"
      
        #product qty
        row << "#{variation.qty_on_hand}"
      
        @rows << row
      end
      
    end #end each variation
  
  
    file_content = @headings.join(",") + "\n"
    for row in @rows
      file_content += row.join(",") + "\n"
    end
  
  
    
    fname = Time.now.strftime("DORM-INV-%m%d%y-%H%M%S.csv")
    
    #transfer to FTP
    self.ftp_transfer_content(
      file_content, 
      "#{fname}", 
      "ftp.torreycommerce.net", 
      "dormbuys", 
      "D0rmBuys333")
    
  end #end method self.update_lnt_inventory
  
  
  def self.post_orders_to_packstream
    
    @orders = Order.find(:all, :conditions => ['sent_to_packstream = ?', false])
    
    for @order in @orders
    
      order_xml = <<-ENDXML
      <?xml version="1.0" encoding="UTF-8"?>
      <orderInformation>
        <order>
          <orderId>#{@order.order_id}</orderId>
          <orderDate>#{@order.order_date.strftime("%m/%d/%Y %H:%I")}</orderDate>
          <userId>#{@order.user_id.blank? ? -1 : @order.user_id}</userId>
          <typeOfCustomer>#{@order.whoami.blank? ? "" : @order.whoami}</typeOfCustomer>
        </order>
        <orderItems>
      ENDXML
    
      
          for oli in @order.order_line_items
            order_xml += <<-ENDXML
            <item>
              <productNumber>#{oli.product_number}</productNumber>
              <productId>#{oli.variation.product.id}</productId>
              <itemName>#{oli.item_name}</itemName>
              <quantity>#{oli.quantity}</quantity>
              <unitPrice>#{oli.unit_price}</unitPrice>
              <total>#{oli.total}</total>
            </item>
            ENDXML
          end
      
      
      order_xml += <<-ENDXML
        </orderItems>
        <customer>
          <firstName>#{@order.user_id.blank? ? @order.billing_first_name : @order.user.first_name}</firstName>
          <lastName>#{@order.user_id.blank? ? @order.billing_last_name : @order.user.last_name}</lastName>
          <email>#{@order.user_id.blank? ? @order.email : @order.user.email}</email>
          <phone>#{@order.user_id.blank? ? @order.billing_phone : @order.user.phone}</phone>
        </customer>  
        <billingAddress>
          <billingFirstName>#{@order.billing_first_name}</billingFirstName>
          <billingLastName>#{@order.billing_last_name}</billingLastName>
          <billingAddress>#{@order.billing_address}</billingAddress>
          <billingCity>#{@order.billing_city}</billingCity>
          <billingState>#{State.find(@order.billing_state_id).full_name}</billingState>
          <billingZipCode>#{@order.billing_zipcode}</billingZipCode>
          <billingCountry>#{Country.find(@order.billing_country_id).country_name}</billingCountry>
          <billingPhone>#{@order.billing_phone}</billingPhone>
        </billingAddress>
        <shippingAddress>
          <shippingFirstName>#{@order.shipping_first_name}</shippingFirstName>
          <shippingLastName>#{@order.shipping_last_name}</shippingLastName>
          <shippingAddress>#{@order.shipping_address}</shippingAddress>
          <shippingCity>#{@order.shipping_city}</shippingCity>
          <shippingState>#{State.find(@order.shipping_state_id).full_name}</shippingState>
          <shippingZipCode>#{@order.shipping_zipcode}</shippingZipCode>
          <shippingCountry>#{Country.find(@order.shipping_country_id).country_name}</shippingCountry>
          <shippingPhone>#{@order.shipping_phone}</shippingPhone>
        </shippingAddress>
      </orderInformation>
      ENDXML
    
      uri = URI.parse("https://api.packstream.com/order.aspx")
      
      req = Net::HTTP::Post.new(uri.request_uri)
      req.form_data = {:data => order_xml}
      
      http_session = Net::HTTP.new(uri.host, uri.port)
      http_session.use_ssl = true
      http_session.start { |http| 
        http.request(req)
      }
    
      @order.skip_all_callbacks
      @order.sent_to_packstream = true
      @order.save(false)
    
   end #end for loop
    
  end #end method self.post_orders_to_packstream
  
  
  def self.update_generic
    @products = Product.find(:all, :conditions => {:visible => true})
    
    xml = %(<?xml version="1.0" encoding="UTF-8"?>\n)
    xml += %(<products>)
    
    for p in @products
      xml += %(<product>)
      xml += %(<product_id>#{p.id}</product_id>\n)
      xml += %(<product_name>#{CGI::escapeHTML(p.product_name)}</product_name>)
      xml += %(<product_overview>#{CGI::escapeHTML(p.product_overview)}</product_overview>)

      xml += %(<image_url><![CDATA[#{p.product_image.url(:main)}]]></image_url>)
      xml += %(<price>#{p.retail_price}</price>)
      xml += %(<msrp>#{p.list_price}</msrp>)
      xml += %(<url><![CDATA[http://dormbuys.com#{p.default_front_url}]]></url>)
      
      xml += %(<variations>)
        for v in p.product_variations
          xml += %(<variation>)
            xml += %(<product_number>#{v.product_number}</product_number>)
            xml += %(<title>#{CGI::escapeHTML(v.title)}</title>)
            xml += %(<full_title>#{CGI::escapeHTML(v.full_title)}</full_title>)
            xml += %(<qty_on_hand>#{v.qty_on_hand}</qty_on_hand>)
            xml += %(<qty_on_hold>#{v.qty_on_hold}</qty_on_hold>)
            xml += %(<msrp>#{v.list_price}</msrp>)
            xml += %(<price>#{v.rounded_retail_price}</price>)
            xml += %(<visible>#{v.visible}</visible>)
          xml += %(</variation>)
        end
      xml += %(</variations>)
      
      xml += %(<categories>)
        for c in p.subcategories
          xml += %(<category>)
            xml += %(<name>#{c.name}</name>)
            xml += %(<description>#{c.description}</description>)
          xml += %(</category>)
        end
      xml += %(</categories>)
      
      xml += %(</product>)
    end #end for loop
    
    xml += %(</products>)
    
    
    ftp_file = "#{RAILS_ROOT}/public/content/files/generic_products.xml"
    fh = File.new(ftp_file, "w")
    fh.puts(xml)
    fh.close
  end #end update_generic
  
  
  def self.update_packstream
    
    @products = Product.find(:all)
    
    xml = %(<?xml version="1.0" encoding="UTF-8"?>\n)
    xml += %(<products>)
    
    for p in @products
      xml += %(<product>)
      xml += %(<product_id>#{p.id}</product_id>\n)
      xml += %(<product_name>#{CGI::escapeHTML(p.product_name)}</product_name>)
      xml += %(<product_overview>#{CGI::escapeHTML(p.product_overview)}</product_overview>)

      xml += %(<image_url><![CDATA[#{p.product_image.url(:main)}]]></image_url>)
      xml += %(<price>#{p.retail_price}</price>)
      xml += %(<msrp>#{p.list_price}</msrp>)
      xml += %(<url><![CDATA[http://dormbuys.com#{p.default_front_url}]]></url>)
      xml += %(<visible>#{p.visible}</visible>)
      
      xml += %(<recommendations>)
      for r in p.recommended_products
        xml += %(<product_id>#{r.id}</product_id>\n)
        xml += %(<product_name>#{CGI::escapeHTML(r.product_name)}</product_name>)
        xml += %(<product_overview>#{CGI::escapeHTML(r.product_overview)}</product_overview>)
        xml += %(<image_url><![CDATA[#{r.product_image.url(:main)}]]></image_url>)
        xml += %(<price>#{r.retail_price}</price>)
        xml += %(<msrp>#{r.list_price}</msrp>)
        xml += %(<url><![CDATA[http://dormbuys.com#{r.default_front_url}]]></url>)
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
          xml += %(<msrp>#{v.list_price}</msrp>)
          xml += %(<price>#{v.rounded_retail_price}</price>)
          xml += %(<visible>#{v.visible}</visible>)
        end
      xml += %(</variations>)
      xml += %(</product>)
    end #end for loop
    
    xml += %(</products>)
    
    
    ftp_file = "#{RAILS_ROOT}/public/content/files/packstream_products.xml"
    fh = File.new(ftp_file, "w")
    fh.puts(xml)
    fh.close
  
  end #end method self.update_packstream
  
  
  def self.get_lnt_product_variations(options={})
    
    variations = []
    
    if options[:new_only]
      product_variations = ProductVariation.find(:all, :conditions => ['products.drop_ship = ? AND product_variations.created_at >= ?', false, 7.days.ago.beginning_of_day], :include => [:product])
      #products = Product.find(:all, :conditions => ['drop_ship = ? AND created_at >= ?', false, 7.days.ago.beginning_of_day], :include => :product_variations)
    else
      product_variations = ProductVariation.find(:all, :conditions => ['products.drop_ship = ?', false], :include => [:product])
      #products = Product.find(:all, :conditions => ['drop_ship = ?', false], :include => :product_variations)
    end
    
    
    product_variations.each do |variation|
      
      #product cost is greater than 2.98 and weight is less than 25 lbs
      if variation.rounded_retail_price > (2.98).to_money && variation.product_packages.collect.sum {|pp| pp.weight } < 25
        variations << variation
      end #end if
      
    end #end each variation
    
    variations
    
    
  end #end method self.get_lnt_product_variations

  
  
  def self.get_lnt_price(variation)
    
    weight = variation.product_packages.collect.sum {|pp| pp.weight}
    starting_price = (variation.rounded_retail_price * 1.10)
    ending_price = starting_price
    
    if weight <= 5
      
      ending_price = starting_price + (8.00).to_money
      
    elsif weight > 5 && weight <= 10
      
      ending_price = starting_price + (9.00).to_money
      
    elsif weight > 10 && weight <= 15
     
     ending_price = starting_price + (9.00).to_money
     
    elsif weight > 15 && weight <= 20
      
      ending_price = starting_price + (10.50).to_money
      
    elsif weight > 20 && weight <= 25
      
      ending_price = starting_price + (12.00).to_money
      
    else
      
      ending_price = starting_price + (12.00).to_money
      
    end
    
    return ending_price
  
  end #end get_lnt_price
  
  
  
  def self.get_lnt_comparison_price(variation)
    
    weight = variation.product_packages.collect.sum {|pp| pp.weight}
    starting_price = variation.list_price
    ending_price = starting_price
    
    if weight <= 5
      
      ending_price = starting_price + (8.00).to_money
      
    elsif weight > 5 && weight <= 10
      
      ending_price = starting_price + (9.00).to_money
      
    elsif weight > 10 && weight <= 15
     
     ending_price = starting_price + (9.00).to_money
     
    elsif weight > 15 && weight <= 20
      
      ending_price = starting_price + (10.50).to_money
      
    elsif weight > 20 && weight <= 25
      
      ending_price = starting_price + (12.00).to_money
      
    else
      
      ending_price = starting_price + (12.00).to_money
      
    end
    
    return ending_price
  
  end #end get_lnt_price
  
  
  
  
  
  def self.ftp_transfer_content(content, file_name, ftp_host, ftp_user, ftp_pass)
    puts "\nUploading #{file_name} to: #{ftp_host}\n"
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
    #print ftp.list('all')

    #clost the FTP connection
    ftp.close
    
  end #end method self.ftp_transfer_content()
  
  
  

end #end class