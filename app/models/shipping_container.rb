class ShippingContainer < ActiveRecord::Base
  
  validates_presence_of :title, :length, :width, :depth, :weight
  validates_numericality_of :length, :width, :depth, :weight
  
  
  def volume
    length * width * depth
  end #end method volume
  
end
