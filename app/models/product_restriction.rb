class ProductRestriction < ActiveRecord::Base
  
  validates_presence_of :state_id, :description
  
  belongs_to :state
  belongs_to :product
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
end
