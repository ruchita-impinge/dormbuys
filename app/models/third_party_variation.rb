class ThirdPartyVariation < ActiveRecord::Base
  
  belongs_to :third_party_category
  has_many :third_party_variation_attributes
  
  validates_presence_of :owner, :name
  
end
