class ProductAsOptionValue < ActiveRecord::Base
  
  belongs_to :product_variation
  belongs_to :product_as_option
  
  validates_presence_of :display_value
  validates_presence_of :price_adjustment
  
  attr_accessor :should_destroy
  
  composed_of :price_adjustment, 
    :class_name => "Money", 
    :mapping => %w(int_price_adjustment cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
  def product
    self.product_variation.product
  end #end method product
  
  
  def product_variation_name=(product_variation_name)
    
    rind = product_variation_name.rindex("-")
    pname = rind ? product_variation_name[0, rind-1] : product_variation_name
    
    products = Product.find(:all, :conditions => ["product_name LIKE ?", "%#{pname}%"])
    found = nil

    for product in products
      found_var = false
      for variation in product.product_variations
        if variation.full_title == product_variation_name
          self.product_variation = variation
          found_var = true
          break
        end
      end
      break if found_var == true
    end

  end #end method product_variation_name


end
