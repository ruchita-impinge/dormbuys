class ProductAsOption < ActiveRecord::Base
  
  belongs_to :product
  has_many :product_as_option_values, :dependent => :delete_all

  validates_presence_of :option_name
  
  after_update :save_product_as_option_values
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
  #mass assignment setter method
  def pao_value_attributes=(pao_val_attributes)
    pao_val_attributes.each do |attributes|
      if attributes[:id].blank?
        product_as_option_values.build(attributes)
      else
        paov = product_as_option_values.detect {|x| x.id == attributes[:id].to_i}
        paov.attributes = attributes
      end
    end
  end #end method pao_value_attributes=(pao_val_attributes)
  
  def save_product_as_option_values
    product_as_option_values.each do |v| 
      if v.should_destroy?
        v.destroy
      else
        v.save(false)
      end
    end
  end #end method save_product_as_option_values
  
end
