class GiftRegistry < ActiveRecord::Base
  
  REGISTRY_FOR_YOU          = 1
  REGISTRY_FOR_YOUR_CHILD   = 2
  REGISTRY_FOR_FRIEND       = 3
  REGISTRY_FOR_ORGANIZATION = 4
  REGISTRY_FOR = [
    [1, "You"],
    [2, "Your Child"],
    [3, "A Friend"],
    [4, "An Organization"]
  ]
  
  REGISTRY_REASON_COLLEGE       = 1
  REGISTRY_REASON_GRADUATION    = 2
  REGISTRY_REASON_BIRTHDAY      = 3
  REGISTRY_REASON_CHRISTMAS     = 4
  REGISTRY_REASON_HANUKAH       = 5
  REGISTRY_REASON_NEW_HOME_APT  = 6
  REGISTRY_REASON_OTHER         = 7
  REGISTRY_REASONS = [
    [1, "Off to College"],
    [2, "Graduation"],
    [3, "Birthday"],
    [4, "Christmas"],
    [5, "Hanukah"],
    [6, "New Home/Apartment"],
    [7, "Other"]
  ]
 
  
  before_create :create_registry_number
  after_update :save_gift_registry_names, :save_gift_registry_items
  
  belongs_to :user
  belongs_to :shipping_state, :class_name => "State", :foreign_key => "shipping_state_id"
  belongs_to :shipping_country, :class_name => "Country", :foreign_key => "shipping_country_id"
  has_many :gift_registry_items, :dependent => :destroy
  has_many :gift_registry_names, :dependent => :destroy
  
  validates_presence_of :registry_reason_id, :registry_for_id, :title, :event_date, :shipping_address, :shipping_city, 
    :shipping_state_id, :shipping_zip_code, :shipping_country_id, :user_id
    
  validates_associated :gift_registry_items
  validates_associated :gift_registry_names
  
  
  def items
    local_items = self.gift_registry_items.reject {|x| x if x.product_variation.blank? }
    local_items.sort{|x,y| x.product_variation.full_title <=> y.product_variation.full_title}
  end #end method items
  
  def last_item_added
    local_items = self.gift_registry_items.reject {|x| x if x.product_variation.blank? }
    local_items.sort!{|x,y| x.id <=> y.id}
    local_items.last
  end #end method last_item_added
  
  def event_type_description
    REGISTRY_REASONS.each do |reason|
      if reason.first == self.registry_reason_id
        return reason.last
      end
    end
  end #end method event_type_description
  
  
  def user_email
    self.user ? self.user.email : ""
  end #end method user_email
  
  def user_email=(email)
    u = User.find_by_email(email)
    self.user = u if u
  end #end method user_email=(email)
  
  
  def gift_registry_name_attributes=(gift_registry_name_attributes)
    
    gift_registry_name_attributes.each do |attributes|
      if attributes[:id].blank?
        name = gift_registry_names.build(attributes)
      else
        name = gift_registry_names.detect {|x| x.id == attributes[:id].to_i}
        name.attributes = attributes if name
      end
      
    end #end loop
    
  end #end method gift_registry_name_attributes=
  
  
  def save_gift_registry_names
    gift_registry_names.each do |x|
      if x.should_destroy?
        x.destroy
      else
        x.save(false)
      end
    end
  end #end method save_gift_registry_names
  
  
  
  
  def gift_registry_item_attributes=(gift_registry_item_attributes)
    
    gift_registry_item_attributes.each do |attributes|
      if attributes[:id].blank?
        item = gift_registry_items.build(attributes)
      else
        item = gift_registry_items.detect {|x| x.id == attributes[:id].to_i}
        item.attributes = attributes if item
      end
      
    end #end loop
    
  end #end method gift_registry_item_attributes=
  
  
  def save_gift_registry_items
    gift_registry_items.each do |x|
      if x.should_destroy?
        x.destroy
      else
        x.save(false)
      end
    end
  end #end method save_gift_registry_items
  
  
  
  def random_string(len)

    #array holding a-z + A-Z + 0-9
    chars = ("A".."Z").to_a + ("0".."9").to_a

    output = ""

    #loop upto the specified length adding a random character
    #from the chars array to the output
    1.upto(len) { |i| output << chars[rand(chars.size-1)] }

    return output

  end #end random_string
  
  
  def create_registry_number
    
    tmp = random_string(8)
    found = GiftRegistry.find_by_registry_number(tmp)
    
    until found.blank?
      tmp  = random_string(8)
      found = GiftRegistry.find_by_registry_number(tmp)
    end
    
    self.registry_number = tmp
    
  end #end method create_registry_number
  
  
  def self.find_by_names(first_name="", last_name="", number="")
    
      conditions = []
      conditions << ["first_name != ?", ""]
      conditions << ["first_name LIKE ?", first_name + "%"] unless first_name.blank?
      conditions << ["last_name LIKE ?", last_name + "%"] unless last_name.blank?      
      names = GiftRegistryName.find(:all, :conditions => [conditions.transpose.first.join(' AND '), *conditions.transpose.last])

      unless number.blank?
        conditions = []
        conditions << ["registry_number LIKE ?", number + "%"] unless number.blank?
        conditions << ["id IN (?)", names.collect{|n| n.gift_registry_id}] unless names.empty?
        found = find(:all, :conditions => [conditions.transpose.first.join(' AND '), *conditions.transpose.last])
      else
        found = find(:all, :conditions => ['id IN (?)', names.collect{|n| n.gift_registry_id}], :order => 'event_date ASC')
      end
      
      #check permissions that the found registries are permissible with a "name" search
      found.reject! {|x| x unless x.show_in_search_by_name == true } unless first_name.blank? && last_name.blank?
      
      #make sure there aren't any registries older than today
      found.reject! {|x| x if x.event_date < Date.today }
      
      #return the results
      found
  end
  
  
  def first_owner
    n = self.gift_registry_names.first
    "#{n.first_name} #{n.last_name}"
  end #end method first_owner
  
  
  def add_cart_item(cart_item)
    item                        = self.gift_registry_items.build
    item.product_variation_id   = cart_item.product_variation_id
    item.desired_qty            = cart_item.quantity
    item.received_qty           = 0
    item.product_options        = cart_item.pov_ids
    item.product_as_options     = cart_item.paov_ids
    item.save
    cart_item.destroy
  end #end method add_cart_item(cart_item)
  
  
end #end class