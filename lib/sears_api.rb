require "builder"
require "rexml/document"

class SearsAPI
  
  EMAIL = "deryl@dormbuys.com"
  PASSWORD = "xavier01"
  UPDATE_INVENTORY_URL = "https://seller.marketplace.sears.com/SellerPortal/api/inventory/fbm/v1?email={emailaddress}&password={password}"
  POST_ITEMS_URL = "https://seller.marketplace.sears.com/SellerPortal/api/catalog/fbm/v1?email={emailaddress}&password={password}"
  
  def items_url
    POST_ITEMS_URL.gsub("{emailaddress}", EMAIL).gsub("{password}", PASSWORD)
  end #end method items_url
  
  def inventory_url
    UPDATE_INVENTORY_URL.gsub("{emailaddress}", EMAIL).gsub("{password}", PASSWORD)
  end #end method inventory_url
  
  def get_builder
    return Builder::XmlMarkup.new(:target => "", :indent => 1)
  end #end method get_builder
  
  def is_restricted(product)
    "No"
  end #end method is_restricted(product)
  
  
  def create_xml_for_items(products)
    xml = get_builder
    xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
    xml.tag!('catalog-feed', "xsi:schemaLocation" => "http://seller.marketplace.sears.com/SellerPortal/s/catalog/item-xml-feed-v1.xsd", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns" => "http://seller.marketplace.sears.com/catalog/v1") do
      xml.tag!('fbm-catalog') do 
        xml.items do 
    
          for product in products
            if product.default_variation?
              
              xml.item("item-id" => product.product_variations.first.product_number) do 
                xml.title product.product_name
                xml.tag! "short-desc", product.product_overview
                xml.upc product.product_variations.first.product_number
                xml.tag! "model-number", product.product_variations.first.product_number
                xml.tag! "standard-price", product.retail_price
                xml.tag! "map-price-indicator", "strict"
                xml.brand (product.brands.size > 0 ? product.brands.first.name : "Dormbuys.com")
                xml.tag! "shipping-length", product.product_variations.first.product_packages.first.length
                xml.tag! "shipping-width", product.product_variations.first.product_packages.first.width
                xml.tag! "shipping-height", product.product_variations.first.product_packages.first.depth
                xml.tag! "shipping-weight", product.product_variations.first.product_packages.first.weight
                xml.tag! "restricted-product", is_restricted(product)
                xml.tag! "image-url" do 
                  xml.url product.product_image(:large)
                  for product.additional_product_images do |ai|
                    xml.url ai.image(:large)
                  end #end for loop on additional_images
                end #end image-url
              end #end item
              
            else # <= multiple variations
              
              for variation in product.product_variations
                xml.tag! "variation-group", "variation-group-id" => 
              end #end for loop on product_variations
              
            end #end if default_variation?
          end #end for loop on products
          
        end #end items
      end #end fbm-catalog
    end #end catalog-feed
    
    return xml
  end #end method create_xml_for_items(products)
  
  
end #end class