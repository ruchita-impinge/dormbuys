class DailyDormDealEmailSubscriber < ActiveRecord::Base
  
  validates_presence_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "must be a valid email address"
  validates_uniqueness_of :email, :message => "is already subscribed"
  
end
