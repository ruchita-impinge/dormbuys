class ShippingRate < ActiveRecord::Base
  
  belongs_to :shipping_rates_table
  
  composed_of :subtotal, 
    :class_name => "Money", 
    :mapping => %w(int_subtotal cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  composed_of :standard_rate,
    :class_name => "Money", 
    :mapping => %w(int_standard_rate cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  composed_of :express_rate, 
    :class_name => "Money", 
    :mapping => %w(int_express_rate cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  composed_of :overnight_rate,
   :class_name => "Money", 
   :mapping => %w(int_overnight_rate cents),
   :converter => Proc.new {|amount| amount.to_money }
  
  
  attr_accessor :should_destroy
  
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
  def validate
    # errors.add(:subtotal, "must be greater than zero") if int_subtotal == 0
    # errors.add(:standard_rate, "must be greater than zero") if int_standard_rate == 0
    # errors.add(:express_rate, "must be greater than zero") if int_express_rate == 0
    # errors.add(:overnight_rate, "must be greater than zero") if int_overnight_rate == 0
  end #end method validate
  
  
end #end class
