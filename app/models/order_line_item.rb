class OrderLineItem < ActiveRecord::Base
  
  after_update :save_shipping_numbers
  
  belongs_to :order
  belongs_to :wish_list_item
  belongs_to :gift_registry_item
  has_many :order_line_item_options, :dependent => :destroy
  has_many :order_line_item_product_as_options, :dependent => :destroy
  has_many :order_line_item_discounts, :dependent => :destroy
  has_many :shipping_numbers, :dependent => :destroy
  
  validates_presence_of :item_name, :quantity, :product_number
  
  attr_accessor :should_destroy, :variation, :gift_registry_item, :wish_list_item
  
    
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
  composed_of :total, 
    :class_name => "Money", 
    :mapping => %w(int_total cents),
    :converter => Proc.new {|amount| amount.to_money }
    
  composed_of :unit_price, 
    :class_name => "Money", 
    :mapping => %w(int_unit_price cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  
  def save_shipping_numbers 
    shipping_numbers.each do |sn|
      if sn.should_destroy?
        sn.destroy
      else
        sn.save(false)
      end
    end
  end #end method save_shipping_numbers
  
  
  def link_object_id
    v = self.get_product_variation
    v ? v.product.id : 0
  end #end method link_object
  
  
  def product_product_number=(value)
    self.product_number = value
  end #end method product_product_number
  
  
  def variation_id=(variation_id)
    self.variation = ProductVariation.find(variation_id)
  end #end method variation_id=(variation_id)
  
  
  def variation
    return get_product_variation
  end #end method variation
  
  
  def get_product_variation
    variation = ProductVariation.find_by_product_number(self.product_number)
    variation = ProductVariation.find_by_manufacturer_number(self.product_manufacturer_number) unless self.product_manufacturer_number.blank? || variation
		product = Product.find_by_product_name(self.item_name.split(" - ").first) unless variation
		variation = product.product_variations.first if product && variation.blank?
		
    variation
  end #end method get_product_variation
  


  def pov_ids=(pov_ids)

    pov_ids.each do |pov_id|

      option_value = ProductOptionValue.find(pov_id)
      oli_option = self.order_line_item_options.build

      oli_option.option_name      = option_value.product_option.option_name
      oli_option.option_value     = option_value.option_value
      oli_option.price_increase   = option_value.price_increase
      oli_option.weight_increase  = option_value.weight_increase

    end #end loop

  end #end method pov_ids=(pov_ids)




  def paov_ids=(paov_ids)

    paov_ids.each do |paov_id|

      option_value = ProductAsOptionValue.find(paov_id)
      oli_pao = self.order_line_item_product_as_options.build

      v = option_value.product_variation

      oli_pao.product_name        = v.product.product_name 
      oli_pao.product_number      = v.product_number
      oli_pao.option_name         = option_value.product_as_option.option_name
      oli_pao.display_value       = v.title
      oli_pao.price               = v.rounded_retail_price + option_value.price_adjustment

    end #end loop

  end #end method paov_ids=(paov_ids)
  
    
  
end #end class
