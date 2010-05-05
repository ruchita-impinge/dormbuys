class Brand < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :products
  has_and_belongs_to_many :vendors
end
