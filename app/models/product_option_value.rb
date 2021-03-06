class ProductOptionValue < ActiveRecord::Base
  
  attr_accessor :should_destroy
  
  belongs_to :product_option
  
  validates_presence_of :option_value
  
  composed_of :price_increase, 
    :class_name => "Money", 
    :mapping => %w(int_price_increase cents),
    :converter => Proc.new {|amount| amount.to_money }

  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  def option_value_display
    out = "#{option_value} "
    if price_increase.cents > 0
      out += "(+#{price_increase}) "
    elsif price_increase.cents < 0
      out += "(-#{price_increase}) "
    end
    out
  end #end method option_value_display
    
end
