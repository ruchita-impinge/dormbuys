class Subcategory < ActiveRecord::Base  
  
  attr_accessor :skip_validation
  
  before_create :save_permalink_handle
  before_save :set_attachment_filenames
  
  belongs_to :parent, :class_name => "Subcategory", :foreign_key => "parent_id"
  belongs_to :category, :touch => true
  has_and_belongs_to_many :products
  has_and_belongs_to_many :third_party_categories
  has_many :all_children, :class_name => "Subcategory", :foreign_key => "parent_id"
  has_many :visible_children, :class_name => "Subcategory", :foreign_key => "parent_id", :conditions => {:visible => true}
  
  validates_presence_of :name, :description, :keywords, :unless => :skip_validation?
  
  has_attached_file :list_image, :styles => {:original => ["130x132#", :jpg]},
    :default_style => :original,
    :default_url => "/content/images/:class/:attachment/:style_missing.jpg",
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":class/:attachment/:id/:style_:basename.:extension"
    #:url => "/content/images/:class/:attachment/:id/:style_:basename.:extension",
    #:path => ":rails_root/public/content/images/:class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :list_image
  validates_attachment_content_type :list_image, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :list_image, :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
  def skip_validation?
    self.skip_validation == true
  end #end method skip_validation?
  
  def default_front_url
    @handle ||= "/college/#{self.category.permalink_handle}/#{self.permalink_handle}"
    @handle
  end #end method default_front_url
  
  def save_permalink_handle
    hand = self.name.downcase.gsub(/[^\w\.\_]/,'-').gsub(".", "-").gsub("/","-")
    found = Subcategory.find(:all, :conditions => ['permalink_handle LIKE ?', hand])
    self.permalink_handle = (found.size > 0 ? "#{hand}-#{found.size + 1}" : hand)
  end #end method save_permalink_handle
  
  def third_party_cat(third_party)
    cat = self.third_party_categories.reject {|c| c unless c.owner == third_party }.first
    cat ? cat.id : nil
  end #end method third_party_cat(third_party)
  
  
  def third_party_cat_obj(third_party)
    cat = self.third_party_categories.reject {|c| c unless c.owner == third_party }.first
    cat ? cat : nil
  end #end method third_party_cat(third_party)
  
  
  def has_children?
    all_children.size > 0
  end #end method has_children?
  
  
  def has_visible_children?
    visible_children.size > 0
  end #end method has_visible_children?
  

  def is_tertiary?
    !self.parent_id.blank?
  end
  
  def set_attachment_filenames
    self.list_image.instance_write(:file_name, "list_image.jpg") if self.list_image.dirty?
  end #end method set_attachment_filenames
  
  def visible_products
    products = self.products.find(:all, :conditions => {:visible => true})
    products.reject {|p| p if p.available_variations.empty? }
  end #end method visible_products
  
  
  
end
