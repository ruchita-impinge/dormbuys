class Category < ActiveRecord::Base
  
  BATH = 1
  LAUNDRY = 2
  BEDDING = 3
  DECOR = 4
  FURNITURE = 5
  APPLIANCES = 6
  TECH = 7
  SPACE_SAVERS = 8
  PACKAGES = 9
  GIFT_CARDS = 10
  GIFT_CARDS_MORE = 11
  SALE = 12

  named_scope :available, lambda {{ :conditions => {:visible => true}, :order => "display_order ASC" }}
  
  before_create :save_permalink_handle
  before_save :set_attachment_filenames
  
  has_many :subcategories
  
  validates_presence_of :name, :description, :keywords
  
  has_attached_file :banner, :styles => {:original => ["960x364#", :jpg]},
    :default_style => :original,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":class/:attachment/:id/:style_:basename.:extension"
    #:url => "/content/images/:class/:attachment/:id/:style_:basename.:extension",
    #:path => ":rails_root/public/content/images/:class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :banner
  validates_attachment_content_type :banner, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :banner, :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
  
  has_attached_file :featured_image, :styles => {:original => ["80x80#", :jpg]},
    :default_style => :original,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":class/:attachment/:id/:style_:basename.:extension"
    #:url => "/content/images/:class/:attachment/:id/:style_:basename.:extension",
    #:path => ":rails_root/public/content/images/:class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :featured_image
  validates_attachment_content_type :featured_image, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :featured_image, :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
  def default_front_url
    @handle ||= "/college/#{self.permalink_handle}"
    @handle
  end #end method default_front_url
  
  def save_permalink_handle
    hand = self.name.downcase.gsub(/[^\w\.\_]/,'-').gsub(".", "-").gsub("/","-")
    found = Category.find(:all, :conditions => ['permalink_handle LIKE ?', hand])
    self.permalink_handle = (found.size > 0 ? "#{hand}-#{found.size + 1}" : hand)
  end #end method save_permalink_handle
  
  def primary_subcategories
    subcategories.reject {|s| s if s.is_tertiary?}
  end #end method primary_subcategories
  
  
  def visible_primary_subcategories(limit=-1)
    subs = primary_subcategories.reject {|s| s if !s.visible }
    
    if limit == -1
      begin
        return subs.sort{|x,y| x.display_order <=> y.display_order }
      rescue
        return subs
      end
    else
      limited_subs = []
      (0..(limit-1)).each {|index| limited_subs << subs[index] }
      return [] if limited_subs.empty?
      begin
        return limited_subs.reject{|s| s if s.blank? }.sort{|x,y| x.display_order <=> y.display_order }
      rescue
        return limited_subs.reject{|s| s if s.blank? }
      end
    end
    
  end #end method visible_primary_subcategories
  
  
  def self.primary_subcategory_options
    
    options = []
    
    Category.all.each do |cat|
      options << [cat.name, cat.primary_subcategories.collect{|s| [s.name, s.id]}]
    end
    
    options
  end #end method self.primary_subcategory_options
  
  
  def set_attachment_filenames
    self.banner.instance_write(:file_name, "banner.jpg") if self.banner.dirty?
    self.featured_image.instance_write(:file_name, "featured_image.jpg") if self.featured_image.dirty?
  end #end method set_attachment_filenames
  
  

end
