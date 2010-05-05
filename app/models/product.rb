class Product < ActiveRecord::Base
  
  after_update :save_additional_product_images, :save_product_options, :save_product_restrictions,
    :save_product_variations, :save_product_as_options
  
  has_and_belongs_to_many :vendors
  has_and_belongs_to_many :warehouses
  has_and_belongs_to_many :subcategories
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
      :large => "500x500#",
      :main => "250x250#",
      :featured => "100x100#",
      :list => "175x175#",
      :thumb => "50x50#"
    },
    :default_style => :list,
    :url => "/images/:class/:attachment/:id/:style_:basename.:extension",
    :path => ":rails_root/public/images/:class/:attachment/:id/:style_:basename.:extension"
  
  # validates_attachment_presence :product_image
  validates_attachment_content_type :product_image, 
    :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png'],
    :if => :has_product_image?
    
  validates_attachment_size :product_image, 
    :less_than => 1.megabytes, :message => "can't be more than 1MB",
    :if => :has_product_image?
    
  def vendor
    vendors.first
  end #end method vendor
  
  def warehouse
    warehouses.first
  end #end method warehouse
    
    
  def retail_price
    self.product_variations.sort {|a,b| a.rounded_retail_price <=> b.rounded_retail_price }.first.rounded_retail_price
  end #end method retail_price
  
  def list_price
    self.product_variations.sort {|a,b| a.list_price <=> b.list_price }.first.list_price
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
    product_variations.each do |pv|
      if pv.should_destroy?
        pv.destroy
      else
        pv.save(false)
      end
    end
  end #end method save_product_variations
  
  
  
  
  
  
  
  
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