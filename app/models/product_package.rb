class ProductPackage < ActiveRecord::Base
  
  belongs_to :product_variation

  validates_presence_of :weight, :length, :width, :depth
  validates_numericality_of :weight, :length, :width, :depth
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  def to_s
    "Product Package => {L: #{length}, W: #{width}, D: #{depth}, w: #{weight}}"
  end

  def reset_weight
    self.weight = ProductPackage.find(self.id).weight
  end #end method reset_weight
  
end
