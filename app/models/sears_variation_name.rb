class SearsVariationName < ActiveRecord::Base
  
  belongs_to :third_party_category
  has_many :sears_variation_values
  
  validates_presence_of :value
  
end
