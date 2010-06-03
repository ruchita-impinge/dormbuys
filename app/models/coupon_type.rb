class CouponType < ActiveRecord::Base
  
  validates_presence_of :name
  has_many :coupons
  
  DOLLAR = 1
  PERCENTAGE = 2
  FREE_SHIPPING = 3
  TIERED_DOLLAR = 4
  TIERED_PERCENTAGE = 5
end
