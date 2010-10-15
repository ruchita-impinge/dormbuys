class ThirdPartyVariationAttribute < ActiveRecord::Base
  
  belongs_to :third_party_variation
  validates_presence_of :value
  
end
