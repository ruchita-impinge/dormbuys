class State < ActiveRecord::Base
  
  named_scope :us_states, :conditions => {:id => (1..51).to_a}
  named_scope :ca_provinces, :conditions => {:id => (52..64).to_a}
  
  has_many :state_shipping_rates
  
  def self.grouped_options
    [
  		["USA", State.us_states.collect{|s| [s.full_name, s.id]}],
  		["Canada", State.ca_provinces.collect{|p| [p.full_name, p.id]}]
  	]
  end #end method self.grouped_options
  
end
