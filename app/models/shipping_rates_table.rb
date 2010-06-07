class ShippingRatesTable < ActiveRecord::Base
  
  after_update :save_shipping_rates
  
  has_many :shipping_rates, :order => 'int_subtotal ASC'
  validates_associated :shipping_rates
  
  
  def after_validation
    self.errors.clear
    model_association_errors(self, shipping_rates, "Shipping Rate")
  end
  
  def model_association_errors(object, collection, err_prefix="")
    collection.each_with_index do |item,i|
      unless item.valid?
        item.errors.each do |attr, msg|
          object.errors.add("#{err_prefix} - #{attr}", msg)
        end
      end
    end
  end #end method model_association_errors
  
  
  #mass assignment setter method
  def shipping_rate_attributes=(shipping_rate_attributes)
    
    shipping_rate_attributes.each do |attributes|
      if attributes[:id].blank?
        shipping_rates.build(attributes)
      else
        y = shipping_rates.detect {|x| x.id == attributes[:id].to_i}
        y.attributes = attributes
      end
    end
    
  end #end method 
  
  
  
  def save_shipping_rates
    shipping_rates.each do |r|
      if r.should_destroy?
        r.destroy
      else
        r.save(false)
      end
    end
  end #end method
  
  
  
  def self.get_rate(sub_total, service_type = :standard)
    
    unless sub_total.class == Money
      sub_total = sub_total.to_money
    end
    
    
    return Money.new(0) if sub_total.cents == 0
    
    
    @rates = ShippingRate.find(:all, :order => 'int_subtotal DESC')
    found_rate = nil

    
    for rate in @rates
      if sub_total.cents > rate.subtotal.cents
        found_rate = rate
        break
      end
    end
    
    
    
    if found_rate.blank? && sub_total.cents <= @rates.last.subtotal.cents
      return Money.new(0)
    end #end if
    
    
    
    raise "no rate found for #{sub_total.to_s}" if found_rate.blank?
    
    case service_type
      when :standard
        found_rate.standard_rate
      when :express
        found_rate.express_rate
      when :overnight
        found_rate.overnight_rate
    end
    
  end #end method method_name
  
  
  def self.is_enabled?
    self.find(:first).enabled == true
  end #end method self.is_enabled?
  
  
  def self.print_rates(type = "standard_rate")
    desc = []
    desc_rates = ShippingRatesTable.first.shipping_rates.all(:order => "int_subtotal DESC")
    desc_rates.each_with_index do |rate,i|
      if i == 0
        desc << ["#{rate.subtotal}-#{rate.subtotal}", "#{rate.send(type.to_sym)}"]
      else
        desc << ["#{rate.subtotal + Money.new(1)}-#{desc_rates[i-1].subtotal}", "#{rate.send(type.to_sym)}"]
      end
    end
    
    desc << ["0.00-#{desc_rates.last.subtotal}", "0.00"]
    
    return desc.reverse
  end #end method print_rates(type = :standard)
  
  
end #end class
