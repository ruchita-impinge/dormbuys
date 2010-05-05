class OrderLineItemDiscount < ActiveRecord::Base
  
  belongs_to :order_line_item
  
  validates_presence_of :discount_message
  
  composed_of :discount_amount, 
    :class_name => "Money", 
    :mapping => %w(int_discount_amount cents),
    :converter => Proc.new {|amount| amount.to_money }
  
end
