class Subcategory < ActiveRecord::Base  
  
  belongs_to :parent, :class_name => "Subcategory", :foreign_key => "parent_id"
  belongs_to :category
  has_and_belongs_to_many :products
  has_and_belongs_to_many :third_party_categories
  
  validates_presence_of :name, :description, :keywords
  
  has_attached_file :list_image, :styles => {:original => "150x150#"},
    :default_style => :original,
    :url => "/images/:class/:attachment/:id/:style_:basename.:extension",
    :path => ":rails_root/public/images/:class/:attachment/:id/:style_:basename.:extension"
  
  validates_attachment_presence :list_image
  validates_attachment_content_type :list_image, :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :list_image, :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
  
  def third_party_cat(third_party)
    cat = self.third_party_categories.reject {|c| c unless c.owner == third_party }.first
    cat ? cat.id : nil
  end #end method third_party_cat(third_party)
  
  
  def has_children?
    all_children.size > 0
  end #end method has_children?
  
  
  def has_visible_children?
    visible_children.size > 0
  end #end method has_visible_children?
  
  
  def visible_children
    Subcategory.find(:all, :conditions => {:parent_id => self.id, :visible => true})
  end #end method 
  
  
  def all_children
    Subcategory.find(:all, :conditions => {:parent_id => self.id})
  end #end method 


  def has_children?
    all_children.size > 0
  end #end method has_children?


  def is_tertiary?
    !self.parent_id.blank?
  end
  
end
