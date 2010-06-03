# Migration Notes:
#################
# => The coupon structure has changed, there are no longer coupon_discounts primarily because
# => there are no longer tiered discounds (because they were never used).  Instead the value of 
# => the coupon is stored on the coupon record in int_value.  There is a getter and setter that take
# => care of converting this to an int or Money based on the type.  The setter is called before_save, 
# => because at the time of setting value=(val) can't know what type of coupon it is.

class Coupon < ActiveRecord::Base
  
  attr_accessor :temp_value
  
  before_save :set_value, :check_reusable_used, :check_free_shipping
  
  belongs_to :coupon_type
  has_many :orders
  
  validates_presence_of :coupon_number, :description, :coupon_type_id
  validates_uniqueness_of :coupon_number, :case_sensitive => false, :message => ' already exists in the system'
  validates_presence_of :tier_rules, :if => :is_tiered_coupon?
  
  composed_of :min_purchase, 
    :class_name => "Money", 
    :mapping => %w(int_min_purchase cents),
    :converter => Proc.new {|amount|amount.to_money }
  
  
  def is_tiered_coupon?
    coupon_type_id == CouponType::TIERED_DOLLAR || coupon_type_id == CouponType::TIERED_PERCENTAGE
  end #end method is_tiered_coupon?
  
  
  def get_tiered_value(int_dollar_value)
    return 0 unless self.is_tiered_coupon?
    
    #0-10=10, 11-20=20, 21-30=30
    self.tier_rules.split(",").collect {|x| x.rstrip.reverse.rstrip.reverse }.each do |rule|
      range, val = rule.split("=")
      low = range[0,range.index("-")].to_i
      high = range[range.index("-")+1, range.length].to_i
      
      if high == -1 && int_dollar_value >= low
        
        return val.to_i
        
      elsif low <= int_dollar_value && int_dollar_value <= high
        
        return val.to_i
        
      end
      
    end #end loop
    
    #if we are here then the int_dollar_value didn't fall into the range
    return 0
    
  end #end method get_tiered_value
  
  
  def value
    if coupon_type_id == CouponType::DOLLAR
      
      Money.new(self.int_value)
      
    elsif coupon_type_id == CouponType::PERCENTAGE
      
      self.int_value
      
    else
      
      self.int_value
      
    end
  end #end method value
  
  
  def value=(val)
    self.temp_value = val
  end #end method value=(val)
  
  
  
  def set_value
    if self.coupon_type_id == CouponType::DOLLAR
      
      self.int_value = self.temp_value.to_money.cents
      
    elsif self.coupon_type_id == CouponType::PERCENTAGE
      
      self.int_value = self.temp_value.to_i
      
    else
      
      self.int_value = 0
      
    end
  end #end method set_value
  
  
  
  def check_reusable_used
    if self.used == true && self.reusable == true
      self.used = false
      return true
    end
  end #end method check_reusable_used
  
  
  def generate_number

    length = 16

    chars = ("A".."Z").to_a + ("0".."9").to_a

    output = ""

    #loop upto the specified length adding a random character
    #from the chars array to the output
    1.upto(length) { |i| output << chars[rand(chars.size-1)] }

    self.coupon_number = output
    
  end #end method generate_number(length)
  
  
  def check_free_shipping   
    if self.coupon_type_id == CouponType::FREE_SHIPPING
      self.is_free_shipping = true
    end
  end #end method chec
  
  
end
