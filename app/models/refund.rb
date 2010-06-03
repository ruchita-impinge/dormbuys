class Refund < ActiveRecord::Base
  
  validates_presence_of :transaction_id, :user_id, :response_data, :message
  belongs_to :order
  belongs_to :user
  

  composed_of :amount, 
    :class_name => "Money", 
    :mapping => %w(int_amount cents),
    :converter => Proc.new {|amount| amount.to_money }
  
end
