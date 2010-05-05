class Courier < ActiveRecord::Base

  has_many :shipping_numbers
  
  FEDEX = 1
  UPS = 2
  DHL = 3
  USPS = 4
  CANADA_POST = 5
  
  def self.current_courier
    Courier::FEDEX
  end #end method self.current_courier
  
end