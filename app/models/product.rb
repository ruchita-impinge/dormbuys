class Product < ActiveRecord::Base
  
  attr_accessor :skip_all_callbacks
  
  before_create :save_permalink_handle
  before_save :set_attachment_filenames
  
  after_update :save_additional_product_images, :save_product_options, :save_product_restrictions,
    :save_product_variations, :save_product_as_options, :touch_subcategories
  
  has_and_belongs_to_many :vendors
  has_and_belongs_to_many :warehouses
  has_and_belongs_to_many :subcategories
  has_and_belongs_to_many :brands
  has_many :additional_product_images
  has_many :product_options
  has_many :product_restrictions
  has_many :product_variations
  has_many :product_as_options
  
  validates_presence_of :product_name, :product_overview
  validates_associated :additional_product_images
  validates_associated :product_options
  validates_associated :product_restrictions
  validates_associated :product_variations
  
  has_attached_file :product_image, 
    :styles => {
      :large => ["500x500#", :jpg],
      :main => ["277x277#", :jpg],
      :list => ["130x132#", :jpg],
      :recommended => ["131x104#", :jpg],
      :home_thumb => ["75x75#", :jpg],
      :home_popup => ["250x250#", :jpg],
      :thumb => ["51x51#", :jpg]
    },
    :default_style => :list,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":class/:attachment/:id/:style_:basename.:extension"
    #:url => "/content/images/:class/:attachment/:id/:style_:basename.:extension",
    #:path => ":rails_root/public/content/images/:class/:attachment/:id/:style_:basename.:extension"
  
  # validates_attachment_presence :product_image
  #validates_attachment_content_type :product_image, 
  #  :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png'],
  #  :if => :has_product_image?
    
  validates_attachment_size :product_image, 
    :less_than => 1.megabytes, :message => "can't be more than 1MB",
    :if => :has_product_image?
  
  
  
  def validate
    if self.subcategories.empty?
      self.errors.add_to_base "Must have at least one subcategory."
    end
  end #end method validate
  
  
  def default_front_url
    begin
      @handle ||= "/college/#{self.subcategories.first.category.permalink_handle}/#{self.subcategories.first.permalink_handle}/#{self.permalink_handle}"
    rescue
      @handle = "/NO-SUBCAT-ERROR"
    end
    @handle
  end #end method default_front_url
  
  def save_permalink_handle
    hand = self.product_name.downcase.gsub(/[^\w\.\_]/,'-').gsub(".", "-").gsub("/","-")
    found = Product.find(:all, :conditions => ['permalink_handle LIKE ?', hand])
    self.permalink_handle = (found.size > 0 ? "#{hand}-#{found.size + 1}" : hand)
  end #end method save_permalink_handle
    
    
  def set_attachment_filenames
    self.product_image.instance_write(:file_name, "product_image.jpg") if self.product_image.dirty?
  end #end method set_attachment_filenames
    
    
  def vendor
    vendors.first
  end #end method vendor
  
  def warehouse
    warehouses.first
  end #end method warehouse
    
    
  def retail_price
    begin
      self.available_variations.sort {|a,b| a.rounded_retail_price <=> b.rounded_retail_price }.first.rounded_retail_price
    rescue
      "123456.78".to_money
    end
  end #end method retail_price
  
  def list_price
    self.sort {|a,b| a.list_price <=> b.list_price }.first.list_price
  end #end method list_price
  

  def has_product_image?
    self.product_image.file?
  end #end method has_product_image?

  
  # method to handle association objects
  def additional_product_image_attributes=(additional_product_image_attributes)
    additional_product_image_attributes.each do |attributes|
      if attributes[:id].blank?
        additional_product_images.build(attributes) unless attributes.values.all?(&:blank?)
      else
        y = additional_product_images.detect {|x| x.id == attributes[:id].to_i }
        y.attributes = attributes if y
      end
    end
  end #end method


  # method to handle update of association objects
  def save_additional_product_images
    return if self.skip_all_callbacks
    
    additional_product_images.each do |x| 
      if x.should_destroy?
        x.destroy
      else
        x.save(false) 
      end
    end
  end #end method
  
  
  # method to handle update of association objects, the setter for this is dynamically created
  def save_product_options
    return if self.skip_all_callbacks
    
    product_options.each do |o| 
      if o.should_destroy?
        o.destroy
      else
        o.save(false)
      end
    end
  end #end method save_product_options  
  
  
  # method to handle update of association objects, the setter for this is dynamically created
  def save_product_as_options
    return if self.skip_all_callbacks
    
    product_as_options.each do |o| 
      if o.should_destroy?
        o.destroy
      else
        o.save(false)
      end
    end
  end #end method save_product_options
  
  
  #mass assignment setter method
  def product_restriction_attributes=(product_restriction_attributes)
    product_restriction_attributes.each do |attributes|
      if attributes[:id].blank?
        product_restrictions.build(attributes)
      else
        pr = product_restrictions.detect {|x| x.id == attributes[:id].to_i }
        pr.attributes = attributes if pr
      end
    end
  end #end method product_restriction_attributes
  
  
  # method to handle update of association objects
  def save_product_restrictions
    return if self.skip_all_callbacks
    
    product_restrictions.each do |pr| 
      if pr.should_destroy?
        pr.destroy
      else
        pr.save(false)
      end
    end
  end #end method save_product_restrictions
  
  
  
  #mass assignment setter method
  def product_variation_attributes=(product_variation_attributes)
    
    product_variation_attributes.each do |key, pv_attributes|
      
      if pv_attributes.first[:id].blank?
        product_variations.build(pv_attributes.first)
      else
        variation = product_variations.detect {|x| x.id == pv_attributes.first[:id].to_i}
        variation.attributes = pv_attributes.first
      end
      
    end #end loop
    
  end #end method product_variation_attributes=(product_variation_attributes)
  
  
  def save_product_variations
    return if self.skip_all_callbacks
    
    product_variations.each do |pv|
      if pv.should_destroy?
        pv.destroy
      else
        pv.save(false)
      end
    end
  end #end method save_product_variations
  
  
  
  ##
  # method to see if the product has any product_options, product_as_options, or 
  # custom_options.
  ##
  def has_options?
    result = false
    
    if product_options.size > 0
      result = true if product_options.first.product_option_values.size > 0
    end
    
    if product_as_options.size > 0
      result = true if product_as_options.first.product_as_option_values.size > 0
    end
    
    result = true if available_variations.size > 1
    
    result
  end #end method has_options?
  
  
  
  def default_variation?
    self.product_variations.size == 1 && self.product_variations.first.title.downcase == "default"
  end #end method default_variation?
  
  
  #product variations that are currently available for sale
  def available_variations
    self.product_variations.find(:all, :conditions => ["visible = ? AND qty_on_hand >= ?", true, 1])
  end #end method available_variations
  
  
  
  def recommended_products
    
    pids = self.subcategories.first.product_ids.reject {|p| p if p == self.id}
    recommended = Product.find_by_sql(%(select distinct p.* from products p, product_variations pv where pv.product_id = p.id AND p.id IN (#{pids.join(",")}) AND pv.visible = 1 AND pv.qty_on_hand >= 1 and p.visible = 1 ORDER BY RAND() LIMIT 2;))
    
  end #end method recommended_products
  
  
  
  def self.random_featured_products(nums = 4)
    
    
    randoms = []

      sql_str = %(
      SELECT
        p.*
      FROM
        products p, 
        product_variations pv
      WHERE
        pv.qty_on_hand > 0
        AND pv.visible = 1
        AND p.featured_item = 1
        AND pv.product_id = p.id
      )
      
      products = Product.find_by_sql(sql_str)
      
      nums.times do
        
        r = rand(products.size)
      
        while randoms.include? products[r] || products[r].featured_image == ""
          r = rand(products.size)
        end
        
        randoms << products[r]
        
      end #end nums.times
      
      randoms
    
  end #end method self.random_featured_products()
  
  
  
  
  def touch_subcategories
    self.subcategories.each do |sub|
      sub.skip_validation = true
      sub.touch
    end
  end #end method touch_subcategories
  
  
  
  
  
  
  def method_missing(method_sym, *arguments, &block)

    if method_sym.to_s =~ /product_option_attributes/
      
      define_dynamic_options_setter(method_sym)
      send(method_sym, arguments.first)
      
    elsif method_sym.to_s =~ /product_as_option_attributes/
      
      define_dynamic_pao_setter(method_sym)
      send(method_sym, arguments.first)
      
    else
      super
    end
    
  end #end method_missing
  
  
  def respond_to?(method_sym, include_private = false)
    if method_sym.to_s =~ /product_option_attributes/
      true
    elsif method_sym.to_s =~ /product_as_option_attributes/
      true
    else
      super
    end
  end #end respond_to?

  
  
  
  protected
  
  def define_dynamic_options_setter(meth)
                
    class_eval <<-RUBY
      def #{meth}(args)
        if args[:id].blank?
          product_options.build(args) unless args.values.all?(&:blank?)
        else
          opt = product_options.detect {|x| x.id == args[:id].to_i}
          opt.attributes = args if opt
        end
      end                              
    RUBY
    
  end
  
  
  def define_dynamic_pao_setter(meth)

    class_eval <<-RUBY
      def #{meth}(args)
        if args[:id].blank?
          product_as_options.build(args) unless args.values.all?(&:blank?)
        else
          opt = product_as_options.detect {|x| x.id == args[:id].to_i}
          opt.attributes = args if opt
        end
      end                              
    RUBY

  end #end method define_dynamic_pao_setter(meth)
  

end #end class