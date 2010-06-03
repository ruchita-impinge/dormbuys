class GiftRegistryItem < ActiveRecord::Base
  
  FIELD_DIVIDER = "^v^"
  CUSTO_DIVIDER = "V^!^V"
  
  belongs_to :gift_registry
  belongs_to :product_variation
  validates_presence_of :product_variation_id, :desired_qty, :received_qty
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  def product_variation_name
    self.product_variation ? self.product_variation.full_title : ""
  end #end method product_variation_name
  

  def product_options
    self.product_option_values ? self.product_option_values.split(FIELD_DIVIDER) : nil
  end #end method product_options
  
  def product_options=(arr)
    self.product_option_values = arr.join(FIELD_DIVIDER) unless arr.blank?
  end #end method product_options=(arr)
  
  
  
  def product_as_options
    self.product_as_option_values ? self.product_as_option_values.split(FIELD_DIVIDER) : nil
  end #end method product_as_options
  
  def product_as_options=(arr)
    self.product_as_option_values = arr.join(FIELD_DIVIDER) unless arr.blank?
  end #end method product_as_options=(arr)
  
  
  
  def product_custom_options
    
    return [nil, nil] if self.product_custom_option_values.blank?
    
    temp = self.product_custom_option_values.split(FIELD_DIVIDER)
    opts = vals = []
    temp.each do |str|
      xarr = str.split(CUSTO_DIVIDER)
      opts << xarr.first
      vals << xarr.last
    end
    
    [opts, vals]
  end #end method product_custom_options
  
  def product_custom_options=(options={})
    opts = options[:opts]
    vals = options[:vals]
    
    return if opts.blank? 
    
    to_add = []
    opts.each_with_index do |o|
      to_add << "#{o}#{CUSTO_DIVIDER}#{vals[i]}"
    end
    self.product_custom_option_values = to_add.join(FIELD_DIVIDER)
  end #end method product_custom_options(opts, vals)
  
  
  def categories
    cats = []
    self.product_variation.product.subcategories.collect{|sub| cats << sub.category}
    cats.uniq
  end #end method categories
  
end
