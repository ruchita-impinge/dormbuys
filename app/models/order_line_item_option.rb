class OrderLineItemOption < ActiveRecord::Base
  
  belongs_to :order_line_item
  
  validates_presence_of :option_name, :option_value
  
  composed_of :price_increase, 
    :class_name => "Money", 
    :mapping => %w(int_price_increase cents),
    :converter => Proc.new {|amount| amount.to_money }
  
end
