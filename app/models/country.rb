class Country < ActiveRecord::Base

  named_scope :ship_to_countries, :conditions => {:ship_to_enabled => true}

end
