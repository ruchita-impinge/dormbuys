class AdditionalProductImage < ActiveRecord::Base
  
  attr_accessor :should_destroy
  
  belongs_to :product
  
  has_attached_file :image, 
    :styles => {
      :large => "500x500#",
      :main => "250x250#",
      :thumb => "50x50#"
    },
    :default_style => :thumb,
    :url => "/images/:class/:attachment/:id/:style_:basename.:extension",
    :path => ":rails_root/public/images/:class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :image, :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
end
