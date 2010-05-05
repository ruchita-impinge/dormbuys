class OrderLineItemProductAsOption < ActiveRecord::Base
  
  belongs_to :order_line_item
  
  validates_presence_of :option_name, :display_value, :product_name, :product_number
  
  composed_of :price, 
    :class_name => "Money", 
    :mapping => %w(int_price cents),
    :converter => Proc.new {|amount| amount.to_money }
  
end
