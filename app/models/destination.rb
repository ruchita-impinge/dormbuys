class Destination < ActiveRecord::Base
  
  validates_presence_of :postal_code, :city, :state_province
  
end
