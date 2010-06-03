class OrderDropShipEmail < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :vendor
  
  validates_presence_of :vendor_id, :email, :vendor_company_name
  
end
