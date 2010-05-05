class ProductOption < ActiveRecord::Base

  attr_accessor :should_destroy
  after_update :save_product_option_values
  
  belongs_to :product
  has_many :product_option_values
  
  validates_presence_of :option_name
  validates_associated :product_option_values
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
  #mass assignment setter method
  def option_value_attributes=(option_value_attributes)
        
    option_value_attributes.each do |attributes|  
      if attributes[:id].blank?
        product_option_values.build(attributes)
      else
        val = product_option_values.detect {|v| v.id == attributes[:id].to_i }
        val.attributes = attributes
      end
    end
    
  end #end method option_value_attributes=(option_value_attributes)

  def save_product_option_values
    
    product_option_values.each do |v|
      
      if v.should_destroy?
        v.destroy
      else
        v.save(false)
      end
      
    end
    
  end #end method save_product_option_values
  
  
end
