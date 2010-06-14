class Vendor < ActiveRecord::Base
    
  belongs_to :state
  belongs_to :billing_state, :foreign_key => "billing_state_id", :class_name => "State"
  belongs_to :country
  belongs_to :billing_country, :foreign_key => "billing_country_id", :class_name => "Country"
  has_many :warehouses
  has_and_belongs_to_many :brands
  has_and_belongs_to_many :products
  has_and_belongs_to_many :vendor_managers, :join_table => "users_vendors", :foreign_key => "vendor_id", :class_name => "User"
  has_and_belongs_to_many :orders
  
  validates_presence_of :account_number, :company_name, :address, :city, :state_id, :zipcode, :country_id,
    :phone
    
  validates_numericality_of :state_id, :country_id
  validates_uniqueness_of :company_name, :case_sensitive => false, :message => '- A vendor with the same name already exists.'
  
  
end
