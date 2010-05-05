class ShippingLabel < ActiveRecord::Base
  
  validates_presence_of :label, :tracking_number
  belongs_to :order
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
  def label_path
    "#{APP_CONFIG['filesystem']['web_labels_path']}/#{self.label}"
  end #end method label_path
  
  ##
  # Function to handle the deletion of the physical file from the filesystem before deleting the 
  # database record
  ##
  def before_destroy
    
    del_path = "#{SHIP_LABELS_STORE}/#{self.label}"
    FileUtils.rm del_path, :force => true

  end #end before_destroy
  
end
