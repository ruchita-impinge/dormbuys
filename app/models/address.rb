class Address < ActiveRecord::Base
  
  BILLING = 1
  SHIPPING = 2
  DORM_SHIPPING = 3
  
  belongs_to :user
  belongs_to :state
  belongs_to :country
  
  validates_presence_of :first_name, :last_name, :address, :city, :state_id, :zip, :country_id, :phone, :address_type_id
  
end
