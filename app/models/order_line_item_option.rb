class OrderLineItemOption < ActiveRecord::Base
  
  belongs_to :order_line_item
  
  validates_presence_of :option_name, :option_value
  
  composed_of :price_increase, 
    :class_name => "Money", 
    :mapping => %w(int_price_increase cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  
  def price_adjustment_text
    "#{((self.price_increase.cents >= 0) ? '+' : '-')} $#{price_increase}"
  end #end method price_adjustment_text
  
  
  def description
    "#{self.option_name.capitalize}: #{self.option_value.capitalize} #{self.price_adjustment_text}"
  end #end method description
  
  def description_no_price
    "#{self.option_name.capitalize}: #{self.option_value.capitalize}"
  end #end method description
    
  
end
