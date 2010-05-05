class ShippingContainer < ActiveRecord::Base
  
  validates_presence_of :title, :length, :width, :depth, :weight
  validates_numericality_of :length, :width, :depth, :weight
  
end
