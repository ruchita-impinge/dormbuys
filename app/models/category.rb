class Category < ActiveRecord::Base
  
  has_many :subcategories
  
  validates_presence_of :name, :description, :keywords
  
  has_attached_file :banner, :styles => {:original => "780x310#"},
    :default_style => :original,
    :url => "/images/:class/:attachment/:id/:style_:basename.:extension",
    :path => ":rails_root/public/images/:class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :banner
  validates_attachment_content_type :banner, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :banner, :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
  
  has_attached_file :featured_image, :styles => {:original => "80x80#"},
    :default_style => :original,
    :url => "/images/:class/:attachment/:id/:style_:basename.:extension",
    :path => ":rails_root/public/images/:class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :featured_image
  validates_attachment_content_type :featured_image, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :featured_image, :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
  
  def primary_subcategories
    subcategories.reject {|s| s if s.is_tertiary? }
  end #end method primary_subcategories
  
  
  def self.primary_subcategory_options
    
    options = []
    
    Category.all.each do |cat|
      options << [cat.name, cat.primary_subcategories.collect{|s| [s.name, s.id]}]
    end
    
    options
  end #end method self.primary_subcategory_options
  

end
