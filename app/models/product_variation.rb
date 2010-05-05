class ProductVariation < ActiveRecord::Base
  
  attr_accessor :should_destroy
  
  after_update :save_product_packages
  
  belongs_to :product
  has_many :product_packages
  has_many :product_as_option_values
  
  validates_uniqueness_of :product_number
  validates_presence_of :title, :qty_on_hand, :qty_on_hold, :reorder_qty, :product_number,
    :wh_row, :wh_bay, :wh_shelf, :wh_product
  
  composed_of :wholesale_price, 
    :class_name => "Money", 
    :mapping => %w(int_wholesale_price cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  composed_of :freight_in_price, 
    :class_name => "Money", 
    :mapping => %w(int_freight_in_price cents),
    :converter => Proc.new {|amount| amount.to_money }
    
  composed_of :drop_ship_fee, 
    :class_name => "Money", 
    :mapping => %w(int_drop_ship_fee cents),
    :converter => Proc.new {|amount| amount.to_money }
    
  composed_of :shipping_in_price, 
    :class_name => "Money", 
    :mapping => %w(int_shipping_in_price cents),
    :converter => Proc.new {|amount| amount.to_money }
    
  composed_of :list_price, 
    :class_name => "Money", 
    :mapping => %w(int_list_price cents),
    :converter => Proc.new {|amount| amount.to_money }

  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  #depreciated method
  def fixed_shipping
    Money.new(0)
  end #end method fixed_shipping
  
  #depreciated method
  def integrated_shipping
    Money.new(0)
  end #end method integrated_shipping
  
  
  def total_wholesale_price
    self.wholesale_price + self.freight_in_price + self.drop_ship_fee
  end


  def retail_price
    self.markup = 0 if self.markup.blank?

    mu = self.markup >= 1 ? (self.markup / 100.0) : self.markup
    rtail_price = self.total_wholesale_price / (1.0 - mu)
  end


  def total_retail_price
    self.retail_price + self.shipping_in_price
  end


  def rounded_retail_price
    tr_cents = self.total_retail_price.to_s.split(".").last.to_i
    adj_cents = 0

    if tr_cents <= 49
      adj_cents = 49 - tr_cents
    elsif tr_cents <= 99
      adj_cents = 99 - tr_cents
    end

    if adj_cents < 10
      adj_cents_str = "0.0#{adj_cents}"
    else
      adj_cents_str = "0.#{adj_cents}"
    end

    self.total_retail_price + adj_cents_str.to_money
  end
  
  
  def full_title
    out = self.product.product_name
    out += " - #{self.title}" unless self.title.downcase == "default"
    out
  end #end method full_title
  
  
  def subcategory
    sub = self.product.subcategories.first
    sub ? sub.name : "UNKNOWN"
  end #end method subcategory
  
  
  def category
    sub = self.product.subcategories.first
    cat = sub.category if sub
    cat ? cat.name : "UNKNOWN"
  end #end method category
  
  
  def warehouse_location
    out = "#{self.wh_row}-#{self.wh_bay}-#{self.wh_shelf}-#{self.wh_product}"
    out.blank? ? "--" : out
  end #end method warehouse_location
  
  
  def self.new_default
    p = ProductVariation.new
    p.product_number = ProductVariation.create_product_number
    p
  end #end method new_default
  
  
  def self.create_product_number
    
    generate_number = Proc.new do 
      len = 10
      #chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      chars = ("0".."9").to_a

      output = ""

      #loop upto the specified length adding a random character
      #from the chars array to the output
      1.upto(len) { |i| output << chars[rand(chars.size-1)] }

      output
    end #end Proc generate_number
    
    pnum  = generate_number.call
    found = ProductVariation.find_by_product_number(pnum)
    until found.blank?
      pnum  = generate_number.call
      found = ProductVariation.find_by_product_number(pnum)
    end
    
    pnum
  end #end method self.create_product_number
  
  
  
  #mass assignment setter method
  def product_package_attributes=(product_package_attributes)    
    product_package_attributes.each do |attributes|
      if attributes[:id].blank?
        z = product_packages.build(attributes)
      else
        pp = product_packages.detect {|x| x.id == attributes[:id].to_i }
        pp.attributes = attributes
      end
    end
  end #end method product_package_attributes=(product_package_attributes)
  
  
  def save_product_packages
    product_packages.each do |pp|
      if pp.should_destroy?
        pp.destroy
      else
        pp.save(false)
      end
    end
  end #end method save_product_packages
  
  
end #end class