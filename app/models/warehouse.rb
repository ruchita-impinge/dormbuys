class Warehouse < ActiveRecord::Base
  
  #relationships
  belongs_to :vendor
  belongs_to :state
  belongs_to :country
  has_and_belongs_to_many :products
  
  #validations
  validates_presence_of :vendor_id
  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :state_id
  validates_presence_of :zipcode
  validates_presence_of :country_id
  
end
