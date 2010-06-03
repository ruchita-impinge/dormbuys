class GiftCardReport < ActiveRecord::Base
  
  validates_presence_of :csv_data, :valid_count, :valid_total, :all_count, :all_total
  
end
