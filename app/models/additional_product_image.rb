class AdditionalProductImage < ActiveRecord::Base
  
  attr_accessor :should_destroy
  
  before_save :set_attachment_filenames
  
  belongs_to :product
  
  has_attached_file :image, 
    :styles => {
      :large => ["500x500#", :jpg],
      :main => ["277x277#", :jpg],
      :thumb => ["50x50#", :jpg]
    },
    :default_style => :thumb,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":class/:attachment/:id/:style_:basename.:extension"
    #:url => "/content/images/:class/:attachment/:id/:style_:basename.:extension",
    #:path => ":rails_root/public/content/images/:class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :image, :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  def set_attachment_filenames
    self.image.instance_write(:file_name, "additional.jpg") if self.image.dirty?
  end #end method set_attachment_filenames
  
  
end
