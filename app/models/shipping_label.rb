class ShippingLabel < ActiveRecord::Base
  
  validates_presence_of :label, :tracking_number, :identification_number
  belongs_to :order
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
  def label_url
    # "#{APP_CONFIG['filesystem']['web_labels_path']}/#{self.label}"
    self.html_url
  end #end method label_url
  
  def graphic_url
    self.label.gsub("#{self.tracking_number}.html", "label#{self.tracking_number}.gif")
  end #end method graphic_url
  
  def html_url
    self.label
  end #end method html_url
  
  ##
  # Function to handle the deletion of the physical file from the filesystem before deleting the 
  # database record
  ##
  def before_destroy
    
    del_html = "#{SHIP_LABELS_STORE}/#{File.basename(self.label)}"
    del_graphic = "#{SHIP_LABELS_STORE}/label#{File.basename(self.label).gsub(".html", ".gif")}"
    FileUtils.rm del_html, :force => true
    FileUtils.rm del_graphic, :force => true

  end #end before_destroy
  
end
