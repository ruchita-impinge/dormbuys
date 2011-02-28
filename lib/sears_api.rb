require "builder"
require "rexml/document"
require 'net/https'
require 'open-uri'

class SearsAPI
  
  DEBUG = false
  
  EMAIL = "deryl@dormbuys.com"
  PASSWORD = "xavier01"
  
  UPDATE_INVENTORY_URL = "https://seller.marketplace.sears.com/SellerPortal/api/inventory/fbm-lmp/v2?email={emailaddress}&password={password}"
  POST_ITEMS_URL = "https://seller.marketplace.sears.com/SellerPortal/api/catalog/fbm/v4?email={emailaddress}&password={password}"
  PROCESSING_REPORT_URL = "https://seller.marketplace.sears.com/SellerPortal/api/reports/v1/processing-report/{documentid}?email={emailaddress}&password={password}"
  VARIATION_PAIR_URL = "https://seller.marketplace.sears.com/SellerPortal/api/attribute/v1/{tag}/attributes?email={emailaddress}&password={password}"
  

  def self.post_initial_products
    variations = ProductVariation.all(:conditions => ['qty_on_hand > 0'])
    pids = variations.collect {|v| v.product_id }
    products = Product.all(:conditions => {:id => pids}, :include => [:product_variations, :subcategories])
    products.reject!{|p| p if p.drop_ship == true || p.visible == false }
    
    puts "\nAPI - Attempting to post #{products.size} products...\n\n"
    
    api = SearsAPI.new
    api.post_products(products)
  end #end method self.post_initial_products
  
  
  def self.post_initial_inventory
    variations = ProductVariation.all(:conditions => ['qty_on_hand > 0'])
    pids = variations.collect {|v| v.product_id }
    products = Product.all(:conditions => {:id => pids}, :include => [:product_variations, :subcategories])
    products.reject!{|p| p if p.drop_ship == true || p.visible == false }
    
    variations_to_post = products.collect{|p| p.product_variations }.flatten
    api = SearsAPI.new
    api.post_inventory(variations_to_post)
  end #end method self.post_initial_inventory
  
  
  def post_inventory(variations)
    xml = create_inventory_xml(variations)
    api_put(inventory_url, xml)
    
    file = File.new("#{RAILS_ROOT}/public/content/integrations/sears_post_inventory.xml", "w")
    file.write(xml)
    file.close
  end #end method post_inventory(variations)
  
  
  def post_products(products_to_post=nil)
    temp_products = products_to_post.blank? ? Product.all(:include => [:product_variations, :subcategories]) : products_to_post
    products = []
    
    temp_products.each do |p|
      if p.primary_subcategory.blank?
        puts "WARNING: Can not post product: (#{p.id} - #{p.product_name}) has no primary subcategory"
      else
        products << p
      end
    end #end each
    
    xml = create_xml_for_items(products)
    api_put(items_url, xml)
    
    
    file = File.new("#{RAILS_ROOT}/public/content/integrations/sears_post_products.xml", "w")
    file.write(xml)
    file.close
    
    
    variation_ids = products.collect {|p| p.product_variations.collect(&:id) }.flatten
    sql = %(UPDATE product_variations SET was_posted_to_sears = 1 WHERE id IN (#{variation_ids.join(",")}); )
    ActiveRecord::Base.connection.execute(sql)
  end #end method post_products
  
  
  def api_put(url, data)
    uri = URI.parse(url)
    
    puts "Sending PUT #{uri.request_uri} to #{uri.host}:#{uri.port}"
    http_session = Net::HTTP.new(uri.host, uri.port)
    http_session.use_ssl = true
    http_session.start do |http|
      headers = {'Content-Type' => 'application/xml; charset=utf-8'}
      put_data = data
      response = http.send_request('PUT', uri.request_uri, put_data, headers)
      #puts "\nResponse #{response.code} #{response.message}: #{response.body}\n\n"
      
      puts "\nResponse #{response.code}: #{response.message}"
      puts "#{'-'*25}\n\n\n"
      doc = REXML::Document.new(response.body)
      error = doc.elements.collect("api-response/error-detail") {|e| e.text() }.join
      doc_id = doc.elements.collect("api-response/document-id") {|e| e.text() }.join
      

      #output payload
      if DEBUG == true
        puts "Payload Data was:\n"
        puts "#{'-'*18}\n"
        puts data
      end
      
      if error
        puts "\n\n\nError Description:\n"
        puts "#{'-'*18}\n"
        puts error
      end
      
      if doc_id
        puts "\n\n\nProcessing report available @: #{processing_report_url(doc_id)}\n"
        puts "#{'-'*160}\n"
      end
      
      puts "\n\n\nResponse Data:\n"
      puts "#{'-'*15}\n"
      puts "#{response.body}\n\n"
      
    end #end http session

  end #end method api_put(url, data)
  
  
  
###[ Methods below are component methods used for the functions above ] ###  

  def variation_pairs_url(tag)
    VARIATION_PAIR_URL.gsub("{tag}", tag).gsub("{emailaddress}", EMAIL).gsub("{password}", PASSWORD)
  end #end method variation_pairs_url(tag)
  
  def items_url
    POST_ITEMS_URL.gsub("{emailaddress}", EMAIL).gsub("{password}", PASSWORD)
  end #end method items_url
  
  def inventory_url
    UPDATE_INVENTORY_URL.gsub("{emailaddress}", EMAIL).gsub("{password}", PASSWORD)
  end #end method inventory_url
  
  def processing_report_url(doc_id)
    PROCESSING_REPORT_URL.gsub("{documentid}", doc_id).gsub("{emailaddress}", EMAIL).gsub("{password}", PASSWORD)
  end #end method processing_report_url
  
  def get_builder
    return Builder::XmlMarkup.new(:target => "", :indent => 1)
  end #end method get_builder
  
  def is_restricted(product)
    false
  end #end method is_restricted(product)
  
  
  def get_category(subcategory)
    cat = subcategory.third_party_cat_obj(ThirdPartyCategory::SEARS)
    if cat
      cat.data #tag is stored in data
    else
      "UNKNOWN"
    end
  end #end method get_category(subcategory)
  
  
  def get_variation_name_attributes(tag)

    uri = URI.parse(variation_pairs_url(tag))
    
    puts "Sending GET #{uri.request_uri} to #{uri.host}:#{uri.port} ==> #{Time.now}"
    http_session = Net::HTTP.new(uri.host, uri.port)
    http_session.use_ssl = true
    http_session.start do |http|
      response = http.send_request('GET', uri.request_uri)

      puts "\nResponse #{response.code}: #{response.message}.... now parsing the xml.... "
      doc = REXML::Document.new(response.body)
      puts "\nXML successfully parsed, constructing hash"
      
      attribute_data = []
      
      doc.elements.collect("attributeFeed/attributes/attribute") do |attribute_element|
        attr_name = attribute_element.attribute("name").value()
        data = {:name => attr_name, :values => []}
        attribute_element.elements.collect("value") do |value_element| 
          data[:values] << value_element.text()
        end # end xml values
        attribute_data << data
      end #end xml attributes
      
      puts "Got data & parsed it ==> #{Time.now}"
      return attribute_data
    end #end http session
    
  end #end method get_variation_name_attributes(tag)
  
  
  
  
  def create_inventory_xml(variations)
    xml = get_builder
    xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
    xml.tag!('store-inventory', "xsi:schemaLocation" => "http://seller.marketplace.sears.com/catalog/v2 http://seller.marketplace.sears.com/SellerPortal/s/schema/rest/inventory/import/v2/store-inventory.xsd", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns" => "http://seller.marketplace.sears.com/catalog/v2") do
      for variation in variations
        xml.tag! "item", "item-id" => variation.product_number do 
          xml.locations do 
            xml.tag! "location", "location-id" => "825738839" do #DB warehouse ID w/ Sears
              xml.quantity variation.qty_on_hand
              xml.tag! "pick-up-now-eligible", false
            end #end location tag
          end #end locations tag
        end #end item
      end #end loop over variations
    end #end tag store-inventory
  end #end method create_inventory_xml(variations)
  
  
  def create_xml_for_items(products)
    xml = get_builder
    xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
    xml.tag!('catalog-feed', "xsi:schemaLocation" => "http://seller.marketplace.sears.com/catalog/v4 ../../../../../rest/catalog/import/v4/lmp-item.xsd", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns" => "http://seller.marketplace.sears.com/catalog/v4") do
      xml.tag!('fbm-catalog') do 
        xml.items do 
    
          for product in products
            if product.default_variation?
              
              xml.item("item-id" => product.product_variations.first.product_number) do 
                xml.title product.product_name
                xml.tag! "short-desc", product.product_overview
                xml.upc product.product_variations.first.upc.blank? ? "00#{product.product_variations.first.product_number}" : product.product_variations.first.upc.gsub(" ", "")
                xml.tags do 
                  xml.primary get_category(product.primary_subcategory)
                end #end tags
                xml.tag! "model-number", product.id
                xml.tag! "standard-price", product.retail_price
                xml.tag! "map-price-indicator", "strict"
                xml.brand (product.brands.size > 0 ? product.brands.first.name : "Dormbuys.com")
                xml.tag! "shipping-length", product.product_variations.first.product_packages.first.length
                xml.tag! "shipping-width", product.product_variations.first.product_packages.first.width
                xml.tag! "shipping-height", product.product_variations.first.product_packages.first.depth
                xml.tag! "shipping-weight", product.product_variations.first.product_packages.first.weight
                xml.tag! "local-marketplace-flags" do
                  xml.tag! "is-restricted", is_restricted(product)
                  xml.tag! "perishable", false
                  xml.tag! "requires-refrigeration", false
                  xml.tag! "requires-freezing", false
                  xml.tag! "contains-alcohol", false
                  xml.tag! "contains-tobacco", false
                end #end local-marketplace-flags tag
                xml.tag! "image-url" do 
                  xml.url product.product_image(:large).split("?").first
                end #end image-url                
                product.additional_product_images.reject {|x| x unless x.image.file? }.each_with_index do |ai, i|
                  if i < 6
                    xml.tag! "feature-image-url" do 
                      xml.url ai.image(:large).split("?").first
                    end #end feature-image-url
                  end #end if
                end #end for loop on additional_images
              end #end item
              
            else # <= multiple variations ##########################################################################
              
              xml.tag! "variation-group", "variation-group-id" => product.id do 
                xml.title product.product_name
                xml.tag! "short-desc", product.product_overview
                xml.tags do 
                  xml.primary get_category(product.primary_subcategory)
                end #end tags
                xml.tag! "model-number", product.id
                xml.brand (product.brands.size > 0 ? product.brands.first.name : "Dormbuys.com")
                xml.tag! "shipping-length", product.product_variations.first.product_packages.first.length
                xml.tag! "shipping-width", product.product_variations.first.product_packages.first.width
                xml.tag! "shipping-height", product.product_variations.first.product_packages.first.depth
                xml.tag! "shipping-weight", product.product_variations.first.product_packages.first.weight
                xml.tag! "local-marketplace-flags" do
                  xml.tag! "is-restricted", is_restricted(product)
                  xml.tag! "perishable", false
                  xml.tag! "requires-refrigeration", false
                  xml.tag! "requires-freezing", false
                  xml.tag! "contains-alcohol", false
                  xml.tag! "contains-tobacco", false
                end #end local-marketplace-flags tag
                xml.tag! "feature-image-url" do 
                  xml.url product.product_image(:large).split("?").first
                end #end feature-image-url                
                product.additional_product_images.reject {|x| x unless x.image.file? }.each_with_index do |ai, i|
                  if i < 5
                    xml.tag! "feature-image-url" do 
                      xml.url ai.image(:large).split("?").first
                    end #end feature-image-url
                  end #end if
                end #end for loop on additional_images
                xml.tag! "variation-items" do 
                  for variation in product.product_variations
                    xml.tag! "variation-item", "item-id" => variation.product_number do 
                      xml.upc variation.upc.blank? ? "00#{variation.product_number}" : variation.upc.gsub(" ", "")
                      xml.tag! "standard-price", variation.rounded_retail_price
                      if variation.image.file?
                        xml.tag! "image-url" do 
                          xml.url variation.image(:large)
                        end #end image-url
                      else
                        xml.tag! "image-url" do 
                          xml.url variation.product.product_image(:large).split("?").first
                        end #end image-url
                      end #end if variation.image
                      xml.tag! "variation-attributes" do 
                        xml.tag! "variation-attribute" do 
                          xml.tag! "attribute", "name" => "#{variation.sears_variation_name}" do 
                            variation.sears_variation_attribute
                          end
                        end #end variation-attribute
                      end #end variation-attributes
                    end #end variation-item
                  end #end for loop on product_variations
                end #end variation-items
              end #end variation-group
              
            end #end if default_variation?
          end #end for loop on products
          
        end #end items
      end #end fbm-catalog
    end #end catalog-feed
  end #end method create_xml_for_items(products)
  
  
end #end class