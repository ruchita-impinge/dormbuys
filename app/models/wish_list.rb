class WishList < ActiveRecord::Base
    
  after_update :save_wish_list_items
  
  belongs_to :user
  has_many :wish_list_items
  
  validates_associated :wish_list_items
  
  
  def items
    local_items = self.wish_list_items.reject {|x| x if x.product_variation.blank? }
    local_items.sort{|x,y| x.product_variation.full_title <=> y.product_variation.full_title}
  end #end method items
  
  
  def user_email
    self.user ? self.user.email : ""
  end #end method user_email
  
  def user_email=(email)
    u = User.find_by_email(email)
    self.user = u if u
  end #end method user_email=(email)
  
  
  def wish_list_item_attributes=(wish_list_item_attributes)
    
    wish_list_item_attributes.each do |attributes|
      if attributes[:id].blank?
        item = wish_list_items.build(attributes)
      else
        item = wish_list_items.detect {|x| x.id == attributes[:id].to_i}
        item.attributes = attributes if item
      end
      
    end #end loop
    
  end #end method wish_list_item_attributes=
  
  
  def save_wish_list_items
    wish_list_items.each do |x|
      if x.should_destroy?
        x.destroy
      else
        x.save(false)
      end
    end
  end #end method save_wish_list_items
  
  
  
end #end class