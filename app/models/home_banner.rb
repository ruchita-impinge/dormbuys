class HomeBanner < ActiveRecord::Base
  
  after_save :update_main
  
  attr_accessor :bypass_update_main
  
  IMAGE_WIDTH = 560
  IMAGE_HEIGHT = 359
  
  has_attached_file :image, 
    :styles => {
      :main => ["560x359#", :jpg],
      :thumb => ["112x72>", :jpg]
    },
    :default_style => :thumb,
    :processors => [:product_picture],
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png'], :if => :has_image?
  validates_attachment_size :image, :less_than => 1.megabytes, :message => "can't be more than 1MB", :if => :has_image?

  
  def self.main
    HomeBanner.find(:first, :conditions => {:is_main => true})
  end #end method self.main
  
  
  def has_image?
    self.image.file?
  end #end method has_image?
  
  
  def update_main
    
    return unless bypass_update_main.blank?
    
    if is_main
      mains = HomeBanner.find(:all, :conditions => {:is_main => true})
      mains.reject!{|x| x if x.id == self.id} unless mains.empty?
      
      mains.each do |x|
        x.bypass_update_main = true
        x.is_main = false
        x.save(false)
      end
    end
    
  end #end method update_home
  
end #end class
