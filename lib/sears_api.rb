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
  
  def get_attribute_name(variation_group_name)
    "ATTR_Name"
  end #end method get_attribute_name(variation_group_name)
  
  def get_category(subcategory)
    cat = subcategory.third_party_cat_obj(ThirdPartyCategory::SEARS)
    if cat
      cat.data #tag is stored in data
    else
      "UNKNOWN"
    end
  end #end method get_category(subcategory)
  
  
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
                xml.tags do 
                  xml.primary get_category(product.subcategories.first)
                end #end tags
                xml.tag! "model-number", product.id
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
                  product.additional_product_images.each do |ai|
                    xml.url ai.image(:large)
                  end #end for loop on additional_images
                end #end image-url
              end #end item
              
            else # <= multiple variations
              
              xml.tag! "variation-group", "variation-group-id" => product.id do 
                xml.title product.product_name
                xml.tag! "short-desc", product.product_overview
                xml.tags do 
                  xml.primary get_category(product.subcategories.first)
                end #end tags
                xml.tag! "model-number", product.id
                xml.brand (product.brands.size > 0 ? product.brands.first.name : "Dormbuys.com")
                xml.tag! "shipping-length", product.product_variations.first.product_packages.first.length
                xml.tag! "shipping-width", product.product_variations.first.product_packages.first.width
                xml.tag! "shipping-height", product.product_variations.first.product_packages.first.depth
                xml.tag! "shipping-weight", product.product_variations.first.product_packages.first.weight
                xml.tag! "restricted-product", is_restricted(product)
                xml.tag! "image-url" do 
                  xml.url product.product_image(:large)
                  product.additional_product_images.each do |ai|
                    xml.url ai.image(:large)
                  end #end for loop on additional_images
                end #end image-url
                xml.tag! "variation-items" do 
                  for variation in product.product_variations
                    xml.tag! "variation-item", "item-id" => variation.product_number do 
                      xml.tag! "standard-price", variation.rounded_retail_price
                      if variation.image.file?
                        xml.tag! "image-url" do 
                          xml.url variation.image(:large)
                        end #end image-url
                      end #end if variation.image
                      
                      if 1 == 2
                      xml.tag! "variation-attributes" do 
                        xml.tag! "variation-attribute" do 
                          xml.tag! "attribute", "name" => "#{get_attribute_name(variation.variation_group)}" do 
                            variation.title
                          end
                        end #end variation-attribute
                      end #end variation-attributes
                      end #end kill-block
                      
                    end #end variation-item
                  end #end for loop on product_variations
                end #end variation-items
              end #end variation-group
              
            end #end if default_variation?
          end #end for loop on products
          
        end #end items
      end #end fbm-catalog
    end #end catalog-feed
    
    return xml
  end #end method create_xml_for_items(products)
  
  
end #end class