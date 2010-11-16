class SearsVariationValue < ActiveRecord::Base
  
  belongs_to :sears_variation_name
  validates_presence_of :value
  
end
