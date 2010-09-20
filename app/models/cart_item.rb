class CartItem < ActiveRecord::Base
  
  FIELD_DIVIDER = "^v^"
  
  before_save :calculate_totals
  
  belongs_to :cart
  belongs_to :product_variation
  belongs_to :wish_list_item
  belongs_to :gift_registry_item
  
  validates_presence_of :cart_id
  
  
  
  composed_of :discount_value, 
    :class_name => "Money", 
    :mapping => %w(int_discount_value cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  composed_of :unit_price, 
    :class_name => "Money", 
    :mapping => %w(int_unit_price cents),
    :converter => Proc.new {|amount| amount.to_money }
    
  composed_of :total_price, 
    :class_name => "Money", 
    :mapping => %w(int_total_price cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  
    
  def title
    self.product_variation.full_title
  end #end method title
  
  
  def is_valid?
    return false if self.product_variation.blank?
    return false if self.product_variation.product.blank?
  end #end method is_valid?
  
  
  
  def thumbnail_url
    self.product_variation.product.product_image(:thumb)
  end #end method thumbnail_url
  
  
  
  def product_link
    self.product_variation.product.default_front_url
  end #end method product_link
  
  
  def product_description
    self.product_variation.product.product_overview
  end #end method product_description
  
  
  
  def product_number
    self.product_variation.product_number
  end #end method product_number
  
  
    
  def pov_ids
    return [] if self.product_option_values.blank?
    self.product_option_values.split(FIELD_DIVIDER)
  end #end method pov_ids
    
    
  def product_options    
    return [] if self.product_option_values.blank?
    
    povs = []
    self.product_option_values.split(FIELD_DIVIDER).each do |pov_id|
      found = ProductOptionValue.find(pov_id)
      povs << found if found
    end
    
    povs    
  end #end method product_options

  def product_options=(arr)
    self.product_option_values = arr.join(FIELD_DIVIDER) unless arr.blank?
  end #end method product_options=(arr)



  def paov_ids
    return [] if self.product_as_option_values.blank?
    self.product_as_option_values.split(FIELD_DIVIDER)
  end #end method pao_ids



  def product_as_options
    return [] if self.product_as_option_values.blank?
    
    paovs = []
    self.product_as_option_values.split(FIELD_DIVIDER).each do |paov_id|
      found = ProductAsOptionValue.find(paov_id)
      paovs << found if found
    end
    
    paovs
  end #end method product_as_options

  def product_as_options=(arr)
    self.product_as_option_values = arr.join(FIELD_DIVIDER) unless arr.blank?
  end #end method product_as_options=(arr)
  


  def calculate_totals
    
    temp_total = self.product_variation.rounded_retail_price
    
    self.product_as_options.each do |paov_id|
      option_value = ProductAsOptionValue.find(paov_id)
      temp_total += option_value.product_variation.rounded_retail_price + option_value.price_adjustment
    end
    
    self.product_options.each do |pov_id|
      option_value = ProductOptionValue.find(pov_id)
      temp_total += option_value.price_increase
    end
    
    
    #now subtract out any discounts
    temp_total -= self.discount_value
    
    #sanity check on quantity
    if self.quantity.blank?
      self.quantity = 1
    end
    
    #now set the prices
    self.unit_price = temp_total
    self.total_price = (temp_total * self.quantity)
    
  end #end method calculate_totals

  
end #end class