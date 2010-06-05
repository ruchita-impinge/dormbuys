class StateShippingRate < ActiveRecord::Base
  
  belongs_to :state
  
  validates_presence_of :state_id
  
  composed_of :additional_cost, 
    :class_name => "Money", 
    :mapping => %w(int_additional_cost cents),
    :converter => Proc.new { |amount| amount.to_money }
  
end
