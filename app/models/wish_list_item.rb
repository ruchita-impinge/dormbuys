class WishListItem < ActiveRecord::Base
  
  FIELD_DIVIDER = "^v^"
  CUSTO_DIVIDER = "V^!^V"
  
  belongs_to :wish_list
  belongs_to :product_variation
  validates_presence_of :product_variation_id, :wish_qty, :got_qty
  
  
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
  
end
