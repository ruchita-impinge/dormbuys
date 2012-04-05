class SiteBanner < ActiveRecord::Base
  
  named_scope :active, lambda {{ :conditions => ['start_at <= ? AND end_at >= ?', Time.now.utc, Time.now.utc], :order => 'start_at desc' }}
  
  validates_presence_of :title, :message, :start_at, :end_at
  
  
  def is_active?
    start_at <= Time.now && end_at >= Time.now
  end #end method is_active?
  
  
  def confirmation_required?
    require_confirmation
  end #end method confirmation_required?
  
  
  def allow_purchase?
    allow_purchase
  end #end method allow_purchase?
  
  
end #end class