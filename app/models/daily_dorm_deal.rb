class DailyDormDeal < ActiveRecord::Base
    
  TYPE_VARIATION = 1
  TYPE_PRODUCT   = 2
  TYPES = [
    [1, "Single Variation"],
    [2, "All Variations of a Product"]
  ]
  
  
  belongs_to :product_variation, :class_name => "ProductVariation", :foreign_key => "product_variation_id"
  belongs_to :product, :class_name => "Product", :foreign_key => "product_id"
  
  
  validates_presence_of :start_time, :end_time, :type_id, :title, :description, :initial_qty
  validates_presence_of :product_variation_id, :if => :is_variation_type?
  validates_presence_of :product_id, :if => :is_product_type?
  
  
  composed_of :original_price, 
    :class_name => "Money", 
    :mapping => %w(int_original_price cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  
  def validate
#validate no overlap
    sql = <<-EOSQL
      ((start_time > ? AND start_time < ?) 
      OR (end_time > ? AND end_time < ?)
      OR (start_time >= ? AND end_time <= ?)
      OR (start_time <= ? AND end_time >= ?))
    EOSQL
    
    condition_vals = [
      start_time.utc, end_time.utc, 
      start_time.utc, end_time.utc,
      start_time.utc, end_time.utc,
      start_time.utc, end_time.utc
    ]
    
    unless self.new_record?
      sql += " AND id != ?"
      condition_vals << self.id
    end
    
    found = DailyDormDeal.all(:conditions => [sql, *condition_vals])
    
    unless found.empty?
      self.errors.add_to_base(
        "Deal overlaps other deals: #{found.collect{|d| "#{d.title} (#{d.start_time.to_s(:full_short_24hr)} - #{d.end_time.to_s(:full_short_24hr)})"}.join(", ")}"
      )
    end

# validate non-zero original price
    if original_price.cents == 0
      self.errors.add_to_base("Original Price must be greater than zero")
    end
    
  end #end method validate
  
  
  def is_variation_type?
    self.type_id == TYPE_VARIATION
  end #end method is_variation_type?
  

  def is_product_type?
    self.type_id == TYPE_PRODUCT
  end #end method is_product_type?

  
  def product_title
    return self.product_variation.full_title unless self.product_variation.blank?
    return self.product.product_name unless self.product.blank?
    return "ERROR" #error catch_all
  end #end method product_title
  
  
  def qty_available
    return self.product_variation.qty_on_hand unless self.product_variation.blank?
    return self.product.product_variations.collect {|pv| pv.qty_on_hand }.sum unless self.product.blank?
    return 0 #error catch_all
  end #end method qty_available
  
  
  # method to show how much % is left, i.e. 77 for 77% of stock remaining
  def level
    (((qty_available * 1.0) / self.initial_qty) * 100).round
  end #end method level
  
  
  def percent_sold
    100 - level
  end #end method percent_sold
  
  
  def percent_remaining
    level
  end #end method percent_remaining
  
  
  def discount_percentage
    begin
      percent = 100 - (((price.cents * 1.0) / original_price.cents) * 100).round
    rescue
      percent = 'ERR'
    end
    "#{percent}%"
  end #end method discount_percentage
  
  
  def self.current_deal

    deal = DailyDormDeal.find(:first, :conditions => ["start_time <= ?", Time.now.utc], :order => 'start_time DESC')
    unless deal
      deal = DailyDormDeal.find(:first, :order => 'start_time DESC')
    end
    deal
  end #end method self.current_deal
  
  
  def next_deal
    found = DailyDormDeal.find(:first, :conditions => ["start_time >= ?", self.end_time.utc], :order => 'start_time ASC')
  end #end method next_deal
  
  
  def seconds_until_start
    self.start_time.to_i - Time.now.to_i
  end #end method seconds_until_start
  
  
  def seconds_left
    self.end_time.to_i - Time.now.to_i
  end #end method seconds_left
  
  
  def is_expired?
    Time.now > self.end_time
  end #end method is_expired?
  
  
  def is_sold_out?
    self.qty_available <= 0
  end #end method is_sold_out?
  
  
  def is_inactive?
    is_expired? || is_sold_out?
  end #end method is_inactive?
  
  
  def is_active?
    !is_inactive?
  end #end method is_active?
  
 
# accessor methods that are independent of product or variation 
  def price
    return self.product_variation.rounded_retail_price unless self.product_variation.blank?
    return self.product.product_variations.sort {|a,b| a.rounded_retail_price <=> b.rounded_retail_price }.first.rounded_retail_price unless self.product.blank?
  end #end method price
  
  
  def main_image
    unless self.product_variation.blank?
      return self.product_variation.image if self.product_variation.image.file?
      return self.product_variation.product.product_image 
    end
    return self.product.product_image unless self.product.blank?
    return "no_image.jpg" #error catch_all
  end #end method main_image
  
  
  def additional_images
    product = self.product_variation.product unless self.product_variation.blank?
    product = self.product unless self.product.blank?
    
    #error catch
    return [] if product.blank?
    
    _additional_images = []
    product.additional_product_images.each do |aimg|
      _additional_images << {:thumb => aimg.image(:thumb), :main => aimg.image(:main), :large => aimg.image(:large), :title => aimg.description, :sort => 1}
    end
    
    product.available_variations.each do |v|
      if v.image.file?
        _additional_images << {:thumb => v.image(:thumb), :main => v.image(:main), :large => v.image(:large), :title => v.title, :sort => 2}
      end
    end
    
    _additional_images.sort! {|x,y| x[:sort] <=> y[:sort]}
  end #end additional_images
  
  
end #end class