class QuantityDiscount < ActiveRecord::Base
  
  NEXT = 0
  EACH = 1
  
  PERCENT = 0
  DOLLAR = 1
  
  before_save :set_value
  
  attr_accessor :temp_value
  
  validates_presence_of :discount_type, :each_next, :buy_qty, :next_qty, :message
  
  has_and_belongs_to_many :product_variations
  
  def validate
    self.errors.add_to_base("Must have at least 1 discounted product variation") if self.product_variations.empty?
  end #end method validate
  
  
  def logic_string
    
    output = "Buy "
    output += "#{buy_qty}" + " and save "
    output += "$" if discount_type == DOLLAR
    output += "#{value}"
    output += "%" if discount_type == PERCENT
    
    if each_next == NEXT
      output += " off the next " + "#{next_qty}"
    elsif each_next == EACH
      output += " off each"
    end
    
    output
    
  end #end method logic_string
  
  
  def value
    if discount_type == DOLLAR
      
      Money.new(self.int_value)
      
    elsif discount_type == PERCENT
      
      self.int_value

    end
  end #end method value
  
  
  
  def value=(val)
    self.temp_value = val
  end #end method value=(val)
  
  
  
  def set_value
    if self.discount_type == DOLLAR
      
      self.int_value = self.temp_value.to_money.cents
      
    elsif self.discount_type == PERCENT
      
      self.int_value = self.temp_value.to_i
      
    end
  end #end method set_value
  
  
end