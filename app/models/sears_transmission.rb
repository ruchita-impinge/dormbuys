class SearsTransmission < ActiveRecord::Base
  
  validates_presence_of :sent_at, :variations
  
  def variation_count
    return 0 if self.variations.blank?
    self.variations.split(",").size
  end #end method variation_count
  
end
