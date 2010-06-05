require "mysql"
require 'digest/sha1'
require 'open-uri'
require 'fileutils'
require 'mime/types'

class DBTransfer
  
  DEMO = true
  CAT_BANNERS_PATH = "/Users/brian/Desktop/db_files/images/products/categories/banners"
  CAT_FEAT_PATH = "/Users/brian/Desktop/db_files/images/products/categories/featured_images"
  SUBCAT_LIST_IMG_PATH = "/Users/brian/Desktop/db_files/images/products/subcategories/list_images"
  PRODUCT_IMG_PATH = "/Users/brian/Desktop/db_files/images/products"
  
  def initialize
    @source = Mysql.real_connect("localhost", "devuser", "2getmein2", "dormbuys_migration_test")
  end #end method initialize
  
  
  def run
    
    @start_time = Time.now
    
    begin
      puts "\nStarting Database Transfer process (#{show_time}) ....\n\n"

      #do the transfer
      execute_transfer_methods
      
    rescue Mysql::Error => e
        puts "Error code: #{e.errno}"
        puts "Error message: #{e.error}"
        puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
        puts "Query:\n #{@last_query}"
    ensure
      # disconnect source db
      @source.close if @source
    end
    
    @end_time = Time.now
    
    puts "\n\nDatabase Transfer complete (#{show_time})\n"
    puts "\nComplete transfer process required: #{complete_elapsed_time}"
    
  end #end method run
  
  
  def show_time
    Time.now.strftime("%H:%M:%S %p")
  end #end method show_time
  
  
  def source_query(query)
    @last_query = query
    @source.query(query)
  end #end method source_query
  
  
  def complete_elapsed_time
    elapsed = (@end_time - @start_time).to_i
    hours = elapsed / 3600
    minutes = (elapsed % 3600) / 60
    seconds = (elapsed % 3600) % 60    
    "#{hours}h #{minutes}m #{seconds}s"
  end #end method complete_elapsed_time
  
  
  
  def temp_file_from_local(local_file)
    
    read_file = File.new(local_file)
    temp_file = Tempfile.new("#{Digest::SHA1.hexdigest(Time.now.to_s)}.jpg")
    while !read_file.eof?
      temp_file.write read_file.read
    end
    
    read_file.close
    
    return temp_file
    
  end #end method temp_file_from_local
  
  
  
  
  def execute_transfer_methods
    #transfer_categories    
    #transfer_subcategories
    #transfer_gift_cards
    #transfer_coupons
    #transfer_orders
    #transfer_order_line_items
    #transfer_order_line_item_product_as_options
    #transfer_order_line_item_options
    #transfer_order_drop_ship_emails
    #transfer_users
    #transfer_users_vendors
    #transfer_products
    #transfer_product_images
    #transfer_additional_product_image_records
    #transfer_additional_product_image_files
    #transfer_product_variations
    #transfer_product_packages
    #transfer_addresses
  end #end method execute_transfer_methods
  
  
  def destroy_categories
    cats = Category.all
    for c in cats
      c.destroy
    end
  end #end method destroy_categories
  
  
  def transfer_categories
    destroy_categories
    
    cats = source_query("SELECT * FROM categories")
    puts "\nBeginning category transfer process (#{show_time}) ....\n"
    
    cats.each_hash do |row|
=begin
      ORIGINAL
      +-----------------------------+--------------+------+-----+---------+----------------+
      | Field                       | Type         | Null | Key | Default | Extra          |
      +-----------------------------+--------------+------+-----+---------+----------------+
      | id                          | int(11)      | NO   | PRI | NULL    | auto_increment |
      | name                        | varchar(50)  | NO   | MUL | NULL    |                |
      | description                 | text         | NO   |     | NULL    |                |
      | keywords                    | text         | NO   |     | NULL    |                |
      | banner_path                 | varchar(255) | YES  |     | NULL    |                |
      | featured_img_path           | varchar(255) | NO   |     | NULL    |                |
      | visible                     | tinyint(1)   | NO   |     | NULL    |                |
      | group_options               | tinyint(1)   | NO   |     | NULL    |                |
      | display_order               | int(11)      | YES  |     | NULL    |                |
      | created_at                  | datetime     | YES  |     | NULL    |                |
      | updated_at                  | datetime     | YES  |     | NULL    |                |
      | old_cat_id                  | int(11)      | YES  |     | NULL    |                |
      | banner_file_name            | varchar(255) | YES  |     | NULL    |                |
      | banner_content_type         | varchar(255) | YES  |     | NULL    |                |
      | banner_file_size            | int(11)      | YES  |     | NULL    |                |
      | banner_updated_at           | datetime     | YES  |     | NULL    |                |
      | featured_image_file_name    | varchar(255) | YES  |     | NULL    |                |
      | featured_image_content_type | varchar(255) | YES  |     | NULL    |                |
      | featured_image_file_size    | int(11)      | YES  |     | NULL    |                |
      | featured_image_updated_at   | datetime     | YES  |     | NULL    |                |
      +-----------------------------+--------------+------+-----+---------+----------------+
      
      NEW
      +-----------------------------+--------------+------+-----+---------+----------------+
      | Field                       | Type         | Null | Key | Default | Extra          |
      +-----------------------------+--------------+------+-----+---------+----------------+
      | id                          | int(11)      | NO   | PRI | NULL    | auto_increment |
      | name                        | varchar(255) | YES  |     | NULL    |                |
      | description                 | text         | YES  |     | NULL    |                |
      | keywords                    | text         | YES  |     | NULL    |                |
      | visible                     | tinyint(1)   | YES  |     | 1       |                |
      | display_order               | int(11)      | YES  |     | 1       |                |
      | created_at                  | datetime     | YES  |     | NULL    |                |
      | updated_at                  | datetime     | YES  |     | NULL    |                |
      | banner_file_name            | varchar(255) | YES  |     | NULL    |                |
      | banner_content_type         | varchar(255) | YES  |     | NULL    |                |
      | banner_file_size            | int(11)      | YES  |     | NULL    |                |
      | banner_updated_at           | datetime     | YES  |     | NULL    |                |
      | featured_image_file_name    | varchar(255) | YES  |     | NULL    |                |
      | featured_image_content_type | varchar(255) | YES  |     | NULL    |                |
      | featured_image_file_size    | int(11)      | YES  |     | NULL    |                |
      | featured_image_updated_at   | datetime     | YES  |     | NULL    |                |
      +-----------------------------+--------------+------+-----+---------+----------------+
      
=end
      id = row["id"]
      banner_path = "original_#{row["banner_file_name"]}."
      feat_img_path = "original_#{row["featured_image_file_name"]}."

      banner_temp = temp_file_from_local("#{CAT_BANNERS_PATH}/#{id}/#{banner_path}")
      feat_temp = temp_file_from_local("#{CAT_FEAT_PATH}/#{id}/#{feat_img_path}")

      new_cat = Category.new
      new_cat.id              = row["id"].to_i
      new_cat.name            = row["name"]
      new_cat.description     = row["description"]
      new_cat.keywords        = row["keywords"]
      new_cat.visible         = row["visible"].to_i == 1 ? true : false
      new_cat.display_order   = row["display_order"].to_i
      new_cat.banner          = banner_temp
      new_cat.featured_image  = feat_temp
      new_cat.save(false)
      
    end #end each_hash
    
    puts "\nCategory transfer process complete (#{show_time})\n"
    
  end #end method transfer_categories
  
  
  def destroy_subcategories
    subs = Subcategory.all
    for s in subs
      s.destroy
    end
  end #end method destroy_subcategories
  
  
  def transfer_subcategories
    destroy_subcategories
    
    cats = source_query("SELECT * FROM subcategories")
    puts "\nBeginning Subcategory transfer process (#{show_time}) ....\n"
    
    cats.each_hash do |row|
      
=begin
    ORIGINAL
    +-------------------------+--------------+------+-----+---------+----------------+
    | Field                   | Type         | Null | Key | Default | Extra          |
    +-------------------------+--------------+------+-----+---------+----------------+
    | id                      | int(11)      | NO   | PRI | NULL    | auto_increment |
    | name                    | varchar(50)  | NO   |     | NULL    |                |
    | description             | text         | NO   |     | NULL    |                |
    | keywords                | text         | NO   |     | NULL    |                |
    | category_id             | int(11)      | YES  |     | NULL    |                |
    | parent_id               | int(11)      | YES  |     | NULL    |                |
    | list_img_path           | varchar(100) | YES  |     | NULL    |                |
    | visible                 | tinyint(1)   | NO   |     | NULL    |                |
    | group_options           | tinyint(1)   | NO   |     | NULL    |                |
    | display_order           | int(11)      | YES  |     | NULL    |                |
    | created_at              | datetime     | YES  |     | NULL    |                |
    | updated_at              | datetime     | YES  |     | NULL    |                |
    | old_sub_cat_id          | int(11)      | YES  |     | NULL    |                |
    | amazon_map_id           | int(11)      | YES  |     | NULL    |                |
    | list_image_file_name    | varchar(255) | YES  |     | NULL    |                |
    | list_image_content_type | varchar(255) | YES  |     | NULL    |                |
    | list_image_file_size    | int(11)      | YES  |     | NULL    |                |
    | list_image_updated_at   | datetime     | YES  |     | NULL    |                |
    +-------------------------+--------------+------+-----+---------+----------------+
    
    NEW
    +-------------------------+--------------+------+-----+---------+----------------+
    | Field                   | Type         | Null | Key | Default | Extra          |
    +-------------------------+--------------+------+-----+---------+----------------+
    | id                      | int(11)      | NO   | PRI | NULL    | auto_increment |
    | name                    | varchar(255) | YES  |     | NULL    |                |
    | description             | text         | YES  |     | NULL    |                |
    | keywords                | text         | YES  |     | NULL    |                |
    | category_id             | int(11)      | YES  |     | NULL    |                |
    | parent_id               | int(11)      | YES  |     | NULL    |                |
    | visible                 | tinyint(1)   | YES  |     | 1       |                |
    | display_order           | int(11)      | YES  |     | 1       |                |
    | created_at              | datetime     | YES  |     | NULL    |                |
    | updated_at              | datetime     | YES  |     | NULL    |                |
    | list_image_file_name    | varchar(255) | YES  |     | NULL    |                |
    | list_image_content_type | varchar(255) | YES  |     | NULL    |                |
    | list_image_file_size    | int(11)      | YES  |     | NULL    |                |
    | list_image_updated_at   | datetime     | YES  |     | NULL    |                |
    +-------------------------+--------------+------+-----+---------+----------------+
    
=end

    id = row["id"]
    list_img_path = "original_#{row["list_image_file_name"]}."
    path_to_temp = "#{SUBCAT_LIST_IMG_PATH}/#{id}/#{list_img_path}"
    list_img_temp = temp_file_from_local(path_to_temp) if File.exists? path_to_temp

    sub = Subcategory.new
    sub.id            = row["id"].to_i
    sub.name          = row["name"]
    sub.description   = row["description"]
    sub.keywords      = row["keywords"]
    sub.category_id   = row["category_id"].to_i
    sub.parent_id     = row["parent_id"].to_i == 0 ? nil : row["parent_id"].to_i
    sub.visible       = row["visible"].to_i == 1 ? true : false
    sub.display_order = row["display_order"].to_i
    if File.exists? path_to_temp
      sub.list_image    = list_img_temp 
      list_img_temp.close
    end
    
    sub.save(false)
      
    end #end each_hash
    
    puts "\nSubcategory transfer process complete (#{show_time})\n"
    
  end #end method transfer_subcategories
  
  
  def destroy_gift_cards
    cards = GiftCard.all
    cards.each do |c|
      c.destroy
    end
  end #end method destroy_gift_cards
  
  
  def transfer_gift_cards
    destroy_gift_cards
    
    records = source_query("SELECT * FROM gift_cards")
    puts "\nBeginning gift card transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +-----------------+-------------+------+-----+---------+----------------+
    | Field           | Type        | Null | Key | Default | Extra          |
    +-----------------+-------------+------+-----+---------+----------------+
    | id              | int(11)     | NO   | PRI | NULL    | auto_increment |
    | giftcard_number | varchar(16) | NO   | MUL | NULL    |                |
    | giftcard_pin    | varchar(6)  | NO   | MUL | NULL    |                |
    | current_amount  | float       | NO   |     | NULL    |                |
    | original_amount | float       | NO   |     | NULL    |                |
    | expires         | tinyint(1)  | NO   |     | NULL    |                |
    | expiration_date | date        | YES  |     | NULL    |                |
    | created_at      | datetime    | YES  |     | NULL    |                |
    | updated_at      | datetime    | YES  |     | NULL    |                |
    +-----------------+-------------+------+-----+---------+----------------+
    

    NEW
    +---------------------+--------------+------+-----+---------+----------------+
    | Field               | Type         | Null | Key | Default | Extra          |
    +---------------------+--------------+------+-----+---------+----------------+
    | id                  | int(11)      | NO   | PRI | NULL    | auto_increment |
    | giftcard_number     | varchar(255) | YES  |     | NULL    |                |
    | giftcard_pin        | varchar(255) | YES  |     | NULL    |                |
    | int_current_amount  | int(11)      | YES  |     | 0       |                |
    | int_original_amount | int(11)      | YES  |     | 0       |                |
    | expires             | tinyint(1)   | YES  |     | NULL    |                |
    | expiration_date     | date         | YES  |     | NULL    |                |
    | created_at          | datetime     | YES  |     | NULL    |                |
    | updated_at          | datetime     | YES  |     | NULL    |                |
    +---------------------+--------------+------+-----+---------+----------------+
=end
    
    records.each_hash do |row|

      new_record = GiftCard.new
      new_record.id               = row["id"].to_i
      new_record.giftcard_number  = row["giftcard_number"]
      new_record.giftcard_pin     = row["giftcard_pin"]
      new_record.current_amount   = Money.new((row["current_amount"].to_f*100).to_i)
      new_record.original_amount  = Money.new((row["original_amount"].to_f*100).to_i)
      new_record.expires          = "#{row["expires"]}".to_i == 1 ? true : false
      new_record.expiration_date  = row["expiration_date"].blank? ? Date.today : Date.parse(row["expiration_date"]) 
      new_record.created_at       = row["created_at"].blank? ? Time.now : Time.parse(row["created_at"]) 
      new_record.updated_at       = row["updated_at"].blank? ? Time.now : Time.parse(row["updated_at"]) 
      new_record.save(false)
      
    end #end each_hash
    
    puts "\nGift card transfer process complete (#{show_time})\n"
    
  end #end method transfer_gift_cards
  
  
  def destroy_coupons
    coups = Coupon.all
    coups.each do |c|
      c.destroy
    end
  end #end method destroy_coupons
    
  
  def transfer_coupons
    destroy_coupons
    
    records = source_query("select c.id, c.coupon_number, c.expires, c.expiration_date, c.reusable, c.used, c.description, c.int_min_purchase, cd.discount_type_id, cd.discount_amount, cd.int_from_amount, cd.int_to_amount from coupons c, coupon_discounts cd where cd.coupon_id = c.id;")
    puts "\nBeginning coupon transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +------------------+--------------+------+-----+---------+----------------+
    | Field            | Type         | Null | Key | Default | Extra          |
    +------------------+--------------+------+-----+---------+----------------+
    | id               | int(11)      | NO   | PRI | NULL    | auto_increment |
    | coupon_number    | varchar(255) | NO   | MUL | NULL    |                |
    | expires          | tinyint(1)   | NO   |     | 1       |                |
    | expiration_date  | date         | YES  |     | NULL    |                |
    | group_options    | tinyint(1)   | NO   |     | NULL    |                |
    | reusable         | tinyint(1)   | NO   |     | 1       |                |
    | used             | tinyint(1)   | NO   |     | 0       |                |
    | description      | varchar(255) | NO   |     | NULL    |                |
    | int_min_purchase | int(11)      | YES  |     | 0       |                |
    +------------------+--------------+------+-----+---------+----------------+
    +------------------+---------+------+-----+---------+----------------+
    | Field            | Type    | Null | Key | Default | Extra          |
    +------------------+---------+------+-----+---------+----------------+
    | id               | int(11) | NO   | PRI | NULL    | auto_increment |
    | coupon_id        | int(11) | NO   | MUL | NULL    |                |
    | discount_type_id | int(11) | NO   |     | NULL    |                |
    | discount_amount  | float   | NO   |     | NULL    |                |
    | int_from_amount  | int(11) | YES  |     | 0       |                |
    | int_to_amount    | int(11) | YES  |     | 0       |                |
    +------------------+---------+------+-----+---------+----------------+
    
    
    
    NEW
    +------------------+--------------+------+-----+---------+----------------+
    | Field            | Type         | Null | Key | Default | Extra          |
    +------------------+--------------+------+-----+---------+----------------+
    | id               | int(11)      | NO   | PRI | NULL    | auto_increment |
    | coupon_number    | varchar(255) | YES  |     | NULL    |                |
    | expires          | tinyint(1)   | YES  |     | 1       |                |
    | expiration_date  | date         | YES  |     | NULL    |                |
    | reusable         | tinyint(1)   | YES  |     | 1       |                |
    | used             | tinyint(1)   | YES  |     | 0       |                |
    | description      | varchar(255) | YES  |     | NULL    |                |
    | int_min_purchase | int(11)      | YES  |     | 0       |                |
    | int_value        | int(11)      | YES  |     | 0       |                |
    | coupon_type_id   | int(11)      | YES  |     | NULL    |                |
    | is_free_shipping | tinyint(1)   | YES  |     | 0       |                |
    | created_at       | datetime     | YES  |     | NULL    |                |
    | updated_at       | datetime     | YES  |     | NULL    |                |
    +------------------+--------------+------+-----+---------+----------------+
    
=end
    
    records.each_hash do |row|

      new_record = Coupon.new
      new_record.id                 = row["id"].to_i
      new_record.coupon_number      = row["coupon_number"]
      new_record.expires            = "#{row["expires"]}".to_i == 1 ? true : false
      new_record.expiration_date    = row["expiration_date"].blank? ? Date.today : Date.parse(row["expiration_date"])
      new_record.reusable           = "#{row["reusable"]}".to_i == 1 ? true : false
      new_record.used               = "#{row["used"]}".to_i == 1 ? true : false
      new_record.description        = row["description"]
      new_record.min_purchase       = Money.new("#{row["int_min_purchase"]}".to_i)
      
      #use old system discount types
      case "#{row["discount_type_id"]}".to_i
        when 1
          new_record.coupon_type_id = CouponType::DOLLAR
        when 2
          new_record.coupon_type_id = CouponType::PERCENTAGE
        when 5
          new_record.coupon_type_id = CouponType::FREE_SHIPPING
          new_record.is_free_shipping = true
      end
      
      new_record.value = row["discount_amount"]
      new_record.save(false)
      
    end #end each_hash
    
    puts "\nCoupon transfer process complete (#{show_time})\n"
    
  end #end method transfer_coupons
  
  
  def destroy_orders
    orders = Order.all
    orders.each do |o|
      o.destroy
    end
  end #end method destroy_orders
  
  
  def transfer_orders
    destroy_orders
    
    records = source_query("select * from orders") unless DEMO == true
    records = source_query("select * from orders limit 200") unless DEMO == false
    puts "\nBeginning order transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +----------------------------+--------------+------+-----+---------+----------------+
    | Field                      | Type         | Null | Key | Default | Extra          |
    +----------------------------+--------------+------+-----+---------+----------------+
    | id                         | int(11)      | NO   | PRI | NULL    | auto_increment |
    | order_id                   | varchar(25)  | NO   | MUL | NULL    |                |
    | order_date                 | datetime     | NO   | MUL | NULL    |                |
    | user_id                    | int(11)      | YES  |     | NULL    |                |
    | user_profile_type_id       | int(11)      | NO   |     | NULL    |                |
    | billing_first_name         | varchar(25)  | NO   | MUL | NULL    |                |
    | billing_last_name          | varchar(25)  | NO   | MUL | NULL    |                |
    | billing_address            | varchar(50)  | NO   | MUL | NULL    |                |
    | billing_address2           | varchar(50)  | YES  |     | NULL    |                |
    | billing_city               | varchar(50)  | NO   |     | NULL    |                |
    | billing_state_id           | int(100)     | NO   |     | NULL    |                |
    | billing_zipcode            | varchar(20)  | NO   |     | NULL    |                |
    | billing_country_id         | int(11)      | NO   |     | NULL    |                |
    | shipping_first_name        | varchar(25)  | NO   | MUL | NULL    |                |
    | shipping_last_name         | varchar(25)  | NO   | MUL | NULL    |                |
    | shipping_address           | varchar(50)  | NO   | MUL | NULL    |                |
    | shipping_address2          | varchar(50)  | YES  |     | NULL    |                |
    | shipping_city              | varchar(50)  | NO   |     | NULL    |                |
    | shipping_state_id          | int(100)     | NO   |     | NULL    |                |
    | shipping_zipcode           | varchar(20)  | NO   |     | NULL    |                |
    | shipping_country_id        | int(11)      | NO   |     | NULL    |                |
    | shipping_phone             | varchar(20)  | YES  |     | NULL    |                |
    | dorm_ship_college_name     | varchar(50)  | YES  |     | NULL    |                |
    | dorm_ship_not_assigned     | tinyint(1)   | YES  |     | 0       |                |
    | dorm_ship_not_part         | tinyint(1)   | YES  |     | 0       |                |
    | dorm_ship_time_id          | int(11)      | YES  |     | NULL    |                |
    | dorm_ship_ship_date        | date         | YES  |     | NULL    |                |
    | tax_id                     | int(11)      | YES  |     | NULL    |                |
    | order_status_id            | int(11)      | NO   | MUL | NULL    |                |
    | order_comments             | text         | YES  |     | NULL    |                |
    | payment_provider_id        | int(11)      | NO   |     | NULL    |                |
    | payment_transaction_number | varchar(255) | NO   |     | NULL    |                |
    | client_ip_address          | varchar(50)  | NO   |     | NULL    |                |
    | coupon_id                  | int(11)      | YES  | MUL | NULL    |                |
    | affiliate_id               | int(11)      | YES  | MUL | NULL    |                |
    | how_heard_option_id        | int(11)      | NO   |     | NULL    |                |
    | how_heard_option_value     | varchar(50)  | YES  |     | NULL    |                |
    | packing_configuration      | text         | YES  |     | NULL    |                |
    | billing_phone              | varchar(20)  | YES  |     | NULL    |                |
    | payment_transaction_data   | text         | YES  |     | NULL    |                |
    | email                      | varchar(50)  | NO   |     | NULL    |                |
    | processed                  | tinyint(1)   | YES  |     | 0       |                |
    | processing                 | tinyint(1)   | YES  |     | 0       |                |
    | int_total_giftcards        | int(11)      | YES  |     | 0       |                |
    | int_total_coupon           | int(11)      | YES  |     | 0       |                |
    | int_total_discounts        | int(11)      | YES  |     | 0       |                |
    | int_subtotal               | int(11)      | YES  |     | 0       |                |
    | int_tax                    | int(11)      | YES  |     | 0       |                |
    | int_shipping               | int(11)      | YES  |     | 0       |                |
    | int_grand_total            | int(11)      | YES  |     | 0       |                |
    | whoami                     | varchar(255) | YES  |     | NULL    |                |
    | order_vendor_id            | int(11)      | YES  |     | 1       |                |
    | sent_to_packstream         | tinyint(1)   | YES  |     | 0       |                |
    +----------------------------+--------------+------+-----+---------+----------------+
    
    
    NEW
    +----------------------------+--------------+------+-----+---------+----------------+
    | Field                      | Type         | Null | Key | Default | Extra          |
    +----------------------------+--------------+------+-----+---------+----------------+
    | id                         | int(11)      | NO   | PRI | NULL    | auto_increment |
    | order_id                   | varchar(255) | YES  |     | NULL    |                |
    | order_date                 | datetime     | YES  |     | NULL    |                |
    | user_id                    | int(11)      | YES  |     | NULL    |                |
    | user_profile_type_id       | int(11)      | YES  |     | NULL    |                |
    | billing_first_name         | varchar(255) | YES  |     | NULL    |                |
    | billing_last_name          | varchar(255) | YES  |     | NULL    |                |
    | billing_address            | varchar(255) | YES  |     | NULL    |                |
    | billing_address2           | varchar(255) | YES  |     | NULL    |                |
    | billing_city               | varchar(255) | YES  |     | NULL    |                |
    | billing_state_id           | int(11)      | YES  |     | NULL    |                |
    | billing_zipcode            | varchar(255) | YES  |     | NULL    |                |
    | billing_country_id         | int(11)      | YES  |     | NULL    |                |
    | shipping_first_name        | varchar(255) | YES  |     | NULL    |                |
    | shipping_last_name         | varchar(255) | YES  |     | NULL    |                |
    | shipping_address           | varchar(255) | YES  |     | NULL    |                |
    | shipping_address2          | varchar(255) | YES  |     | NULL    |                |
    | shipping_city              | varchar(255) | YES  |     | NULL    |                |
    | shipping_state_id          | int(11)      | YES  |     | NULL    |                |
    | shipping_zipcode           | varchar(255) | YES  |     | NULL    |                |
    | shipping_country_id        | int(11)      | YES  |     | NULL    |                |
    | shipping_phone             | varchar(255) | YES  |     | NULL    |                |
    | dorm_ship_college_name     | varchar(255) | YES  |     | NULL    |                |
    | dorm_ship_not_assigned     | tinyint(1)   | YES  |     | NULL    |                |
    | dorm_ship_not_part         | tinyint(1)   | YES  |     | NULL    |                |
    | dorm_ship_time_id          | int(11)      | YES  |     | NULL    |                |
    | dorm_ship_ship_date        | date         | YES  |     | NULL    |                |
    | order_status_id            | int(11)      | YES  |     | 1       |                |
    | order_comments             | text         | YES  |     | NULL    |                |
    | payment_provider_id        | int(11)      | YES  |     | NULL    |                |
    | payment_transaction_number | varchar(255) | YES  |     | NULL    |                |
    | client_ip_address          | varchar(255) | YES  |     | NULL    |                |
    | coupon_id                  | int(11)      | YES  |     | NULL    |                |
    | how_heard_option_id        | int(11)      | YES  |     | NULL    |                |
    | how_heard_option_value     | varchar(255) | YES  |     | NULL    |                |
    | packing_configuration      | text         | YES  |     | NULL    |                |
    | billing_phone              | varchar(255) | YES  |     | NULL    |                |
    | email                      | varchar(255) | YES  |     | NULL    |                |
    | processed                  | tinyint(1)   | YES  |     | 0       |                |
    | processing                 | tinyint(1)   | YES  |     | 0       |                |
    | int_total_giftcards        | int(11)      | YES  |     | 0       |                |
    | int_total_coupon           | int(11)      | YES  |     | 0       |                |
    | int_total_discounts        | int(11)      | YES  |     | 0       |                |
    | int_subtotal               | int(11)      | YES  |     | 0       |                |
    | int_tax                    | int(11)      | YES  |     | 0       |                |
    | int_shipping               | int(11)      | YES  |     | 0       |                |
    | int_grand_total            | int(11)      | YES  |     | 0       |                |
    | whoami                     | varchar(255) | YES  |     | NULL    |                |
    | created_at                 | datetime     | YES  |     | NULL    |                |
    | updated_at                 | datetime     | YES  |     | NULL    |                |
    | order_vendor_id            | int(11)      | YES  |     | NULL    |                |
    | payment_transaction_data   | text         | YES  |     | NULL    |                |
    +----------------------------+--------------+------+-----+---------+----------------+
=end
    
    records.each_hash do |row|

      new_record = Order.new
      new_record.id                       = row["id"].to_i                     
      new_record.order_id                 = row["order_id"]
      new_record.order_date               = Time.parse(row["order_date"])  
      new_record.user_id                  = row["user_id"] unless row["user_id"].blank?
      new_record.user_profile_type_id     = row["user_profile_type_id"].to_i
      new_record.billing_first_name       = row["billing_first_name"]
      new_record.billing_last_name        = row["billing_last_name"]
      new_record.billing_address          = row["billing_address"]
      new_record.billing_address2         = row["billing_address2"]
      new_record.billing_city             = row["billing_city"]
      new_record.billing_state_id         = row["billing_state_id"].to_i
      new_record.billing_zipcode          = row["billing_zipcode"]
      new_record.billing_country_id       = row["billing_country_id"].to_i
      new_record.shipping_first_name      = row["shipping_first_name"]
      new_record.shipping_last_name       = row["shipping_last_name"]
      new_record.shipping_address         = row["shipping_address"]
      new_record.shipping_address2        = row["shipping_address2"]
      new_record.shipping_city            = row["shipping_city"]
      new_record.shipping_state_id        = row["shipping_state_id"].to_i
      new_record.shipping_zipcode         = row["shipping_zipcode"]
      new_record.shipping_country_id      = row["shipping_country_id"].to_i
      new_record.shipping_phone           = row["shipping_phone"]
      new_record.dorm_ship_college_name   = row["dorm_ship_college_name"]
      new_record.dorm_ship_not_assigned   = row["dorm_ship_not_assigned"].to_i == 1 ? true : false
      new_record.dorm_ship_not_part       = row["dorm_ship_not_part"].to_i == 1 ? true : false
      new_record.dorm_ship_time_id        = row["dorm_ship_time_id"].to_i
      new_record.dorm_ship_ship_date      = Date.parse(row["dorm_ship_ship_date"]) unless row["dorm_ship_ship_date"].blank?
      new_record.order_status_id          = row["order_status_id"].to_i
      new_record.order_comments           = row["order_comments"]
      new_record.payment_provider_id      = row["payment_provider_id"].to_i
      new_record.payment_transaction_number = row["payment_transaction_number"]
      new_record.client_ip_address        = row["client_ip_address"]  
      new_record.coupon_id                = row["coupon_id"].to_i unless row["coupon_id"].blank?
      new_record.how_heard_option_id      = row["how_heard_option_id"].to_i
      new_record.how_heard_option_value   = row["how_heard_option_value"]
      new_record.packing_configuration    = row["packing_configuration"]
      new_record.billing_phone            = row["billing_phone"]
      new_record.email                    = row["email"]
      new_record.processed                = row["processed"].to_i == 1 ? true : false
      new_record.processing               = row["processing"].to_i == 1 ? true : false
      new_record.int_total_giftcards      = row["int_total_giftcards"].to_i
      new_record.int_total_coupon         = row["int_total_coupon"].to_i
      new_record.int_total_discounts      = row["int_total_discounts"].to_i
      new_record.int_subtotal             = row["int_subtotal"].to_i
      new_record.int_tax                  = row["int_tax"].to_i
      new_record.int_shipping             = row["int_shipping"].to_i
      new_record.int_grand_total          = row["int_grand_total"].to_i
      new_record.whoami                   = row["whoami"]
      new_record.order_vendor_id          = row["order_vendor_id"].to_i
      new_record.payment_transaction_data = row["payment_transaction_data"]  
      
      new_record.skip_all_callbacks = true
      new_record.save(false)
      
    end #end each_hash
    
    puts "\nOrder transfer process complete (#{show_time})\n"
  end #end method transfer_orders
  
  
  def destroy_order_line_items
    items = OrderLineItem.all
    items.each do |i|
      i.destroy
    end
  end #end method destroy_order_line_items
  
  
  def transfer_order_line_items
    destroy_order_line_items
    
    records = source_query("select * from order_line_items") unless DEMO == true
    records = source_query("select * from order_line_items limit 200") unless DEMO == false
    puts "\nBeginning order line item transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +-----------------------------+--------------+------+-----+---------+----------------+
    | Field                       | Type         | Null | Key | Default | Extra          |
    +-----------------------------+--------------+------+-----+---------+----------------+
    | id                          | int(11)      | NO   | PRI | NULL    | auto_increment |
    | order_id                    | int(11)      | NO   | MUL | NULL    |                |
    | item_name                   | varchar(100) | NO   |     | NULL    |                |
    | quantity                    | int(11)      | NO   |     | NULL    |                |
    | is_discounted               | tinyint(1)   | NO   |     | 0       |                |
    | is_customized               | tinyint(1)   | NO   |     | 0       |                |
    | has_options                 | tinyint(1)   | NO   |     | 0       |                |
    | vendor_company_name         | varchar(255) | YES  |     | NULL    |                |
    | product_manufacturer_number | varchar(255) | YES  |     | NULL    |                |
    | product_product_number      | varchar(255) | YES  |     | NULL    |                |
    | item_number                 | varchar(255) | YES  |     | NULL    |                |
    | item_manufacturer_number    | varchar(255) | YES  |     | NULL    |                |
    | int_unit_price              | int(11)      | YES  |     | 0       |                |
    | int_total                   | int(11)      | YES  |     | 0       |                |
    | product_drop_ship           | tinyint(1)   | YES  |     | 0       |                |
    | warehouse_location          | varchar(20)  | YES  |     | --      |                |
    +-----------------------------+--------------+------+-----+---------+----------------+
    
    NEW
    +-----------------------------+--------------+------+-----+---------+----------------+
    | Field                       | Type         | Null | Key | Default | Extra          |
    +-----------------------------+--------------+------+-----+---------+----------------+
    | id                          | int(11)      | NO   | PRI | NULL    | auto_increment |
    | order_id                    | int(11)      | YES  |     | NULL    |                |
    | item_name                   | varchar(255) | YES  |     | NULL    |                |
    | quantity                    | int(11)      | YES  |     | NULL    |                |
    | vendor_company_name         | varchar(255) | YES  |     | NULL    |                |
    | product_manufacturer_number | varchar(255) | YES  |     | NULL    |                |
    | product_number              | varchar(255) | YES  |     | NULL    |                |
    | int_unit_price              | int(11)      | YES  |     | 0       |                |
    | int_total                   | int(11)      | YES  |     | 0       |                |
    | product_drop_ship           | tinyint(1)   | YES  |     | NULL    |                |
    | warehouse_location          | varchar(255) | YES  |     | NULL    |                |
    | created_at                  | datetime     | YES  |     | NULL    |                |
    | updated_at                  | datetime     | YES  |     | NULL    |                |
    | wish_list_item_id           | int(11)      | YES  |     | NULL    |                |
    | gift_registry_item_id       | int(11)      | YES  |     | NULL    |                |
    +-----------------------------+--------------+------+-----+---------+----------------+
    
=end
    
    records.each_hash do |row|

      new_record = OrderLineItem.new                  

      new_record.id                          = row["id"].to_i
      new_record.order_id                    = row["order_id"].to_i
      new_record.item_name                   = row["item_name"]
      new_record.quantity                    = row["quantity"].to_i
      new_record.vendor_company_name         = row["vendor_company_name"]
      new_record.product_manufacturer_number = row["product_manufacturer_number"]
      new_record.product_number              = row["product_product_number"]
      new_record.int_unit_price              = row["int_unit_price"].to_i
      new_record.int_total                   = row["int_total"].to_i
      new_record.product_drop_ship           = row["product_drop_ship"].to_i == 1 ? true : false
      new_record.warehouse_location          = row["warehouse_location"]
      new_record.save(false)
      
    end #end each_hash
    
    puts "\nOrder Line Item transfer process complete (#{show_time})\n"
    
  end #end method transfer_order_line_items
  
  
  def destroy_order_line_item_product_as_options
    items = OrderLineItemProductAsOption.all
    items.each do |i|
      i.destroy
    end
  end #end method destroy_order_line_item_product_as_options
  
  
  def transfer_order_line_item_product_as_options
    destroy_order_line_item_product_as_options
    
    records = source_query("select * from order_line_item_product_as_options") unless DEMO == true
    records = source_query("select * from order_line_item_product_as_options limit 200") unless DEMO == false
    puts "\nBeginning order line item product as options transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +--------------------+--------------+------+-----+---------+----------------+
    | Field              | Type         | Null | Key | Default | Extra          |
    +--------------------+--------------+------+-----+---------+----------------+
    | id                 | int(11)      | NO   | PRI | NULL    | auto_increment |
    | order_line_item_id | int(11)      | YES  | MUL | NULL    |                |
    | option_name        | varchar(50)  | YES  |     | NULL    |                |
    | display_value      | varchar(50)  | YES  |     | NULL    |                |
    | int_price          | int(11)      | YES  |     | 0       |                |
    | product_name       | varchar(75)  | YES  |     | NULL    |                |
    | product_number     | varchar(25)  | YES  |     | NULL    |                |
    | product_full_title | varchar(100) | YES  |     | NULL    |                |
    +--------------------+--------------+------+-----+---------+----------------+
    
    NEW
    +--------------------+--------------+------+-----+---------+----------------+
    | Field              | Type         | Null | Key | Default | Extra          |
    +--------------------+--------------+------+-----+---------+----------------+
    | id                 | int(11)      | NO   | PRI | NULL    | auto_increment |
    | order_line_item_id | int(11)      | YES  |     | NULL    |                |
    | option_name        | varchar(255) | YES  |     | NULL    |                |
    | display_value      | varchar(255) | YES  |     | NULL    |                |
    | int_price          | int(11)      | YES  |     | 0       |                |
    | product_name       | varchar(255) | YES  |     | NULL    |                |
    | product_number     | varchar(255) | YES  |     | NULL    |                |
    | created_at         | datetime     | YES  |     | NULL    |                |
    | updated_at         | datetime     | YES  |     | NULL    |                |
    +--------------------+--------------+------+-----+---------+----------------+
    
=end
    
    records.each_hash do |row|

      new_record = OrderLineItemProductAsOption.new                  

      new_record.id                 = row["id"].to_i
      new_record.order_line_item_id = row["order_line_item_id"].to_i
      new_record.option_name        = row["option_name"]
      new_record.display_value      = row["display_value"]
      new_record.int_price          = row["int_price"].to_i
      new_record.product_name       = row["product_name"]
      new_record.product_number     = row["product_number"]
      new_record.save(false)
      
    end #end each_hash
    
    puts "\nOrder Line Item product as option transfer process complete (#{show_time})\n"
  end #end method transfer_order_line_item_product_as_options
  
  
  def destroy_order_line_item_options
    options = OrderLineItemOption.all
    options.each do |o|
      o.destroy
    end
  end #end method destroy_order_line_item_options
  
  
  def transfer_order_line_item_options
    destroy_order_line_item_options
        
    records = source_query("select * from order_line_item_options") unless DEMO == true
    records = source_query("select * from order_line_item_options limit 200") unless DEMO == false
    puts "\nBeginning order line item options transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +--------------------+-------------+------+-----+---------+----------------+
    | Field              | Type        | Null | Key | Default | Extra          |
    +--------------------+-------------+------+-----+---------+----------------+
    | id                 | int(11)     | NO   | PRI | NULL    | auto_increment |
    | order_line_item_id | int(11)     | NO   | MUL | NULL    |                |
    | option_value       | varchar(50) | NO   |     | NULL    |                |
    | weight_increase    | float       | NO   |     | NULL    |                |
    | int_price_increase | int(11)     | YES  |     | 0       |                |
    | option_name        | varchar(25) | YES  |     | NULL    |                |
    +--------------------+-------------+------+-----+---------+----------------+
    
    NEW
    +--------------------+--------------+------+-----+---------+----------------+
    | Field              | Type         | Null | Key | Default | Extra          |
    +--------------------+--------------+------+-----+---------+----------------+
    | id                 | int(11)      | NO   | PRI | NULL    | auto_increment |
    | order_line_item_id | int(11)      | YES  |     | NULL    |                |
    | option_name        | varchar(255) | YES  |     | NULL    |                |
    | option_value       | varchar(255) | YES  |     | NULL    |                |
    | weight_increase    | decimal(6,3) | YES  |     | 0.000   |                |
    | int_price_increase | int(11)      | YES  |     | 0       |                |
    | created_at         | datetime     | YES  |     | NULL    |                |
    | updated_at         | datetime     | YES  |     | NULL    |                |
    +--------------------+--------------+------+-----+---------+----------------+
    
=end
    
    records.each_hash do |row|

      new_record = OrderLineItemOption.new                  

      new_record.id                 = row["id"].to_i
      new_record.order_line_item_id = row["order_line_item_id"].to_i
      new_record.option_name        = row["option_name"]
      new_record.option_value       = row["option_value"]
      new_record.weight_increase    = row["weight_increase"].to_f
      new_record.int_price_increase = row["int_price_increase"].to_i
      new_record.save(false)
      
    end #end each_hash
    
    puts "\nOrder Line Item options transfer process complete (#{show_time})\n"
    
  end #end method transfer_order_line_item_options
  
  
  def destroy_order_drop_ship_emails
    emails = OrderDropShipEmail.all
    emails.each do |e|
      e.destroy
    end
  end #end method destroy_order_drop_ship_emails
  
  
  def transfer_order_drop_ship_emails
    destroy_order_drop_ship_emails

    records = source_query("select * from order_drop_ship_emails") unless DEMO == true
    records = source_query("select * from order_drop_ship_emails limit 200") unless DEMO == false
    puts "\nBeginning order drop ship email transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +------------+-------------+------+-----+---------+----------------+
    | Field      | Type        | Null | Key | Default | Extra          |
    +------------+-------------+------+-----+---------+----------------+
    | id         | int(11)     | NO   | PRI | NULL    | auto_increment |
    | order_id   | int(11)     | NO   |     | NULL    |                |
    | vendor_id  | int(11)     | NO   |     | NULL    |                |
    | email      | varchar(50) | NO   |     | NULL    |                |
    | created_at | datetime    | YES  |     | NULL    |                |
    | updated_at | datetime    | YES  |     | NULL    |                |
    +------------+-------------+------+-----+---------+----------------+
    
    NEW
    +---------------------+--------------+------+-----+---------+----------------+
    | Field               | Type         | Null | Key | Default | Extra          |
    +---------------------+--------------+------+-----+---------+----------------+
    | id                  | int(11)      | NO   | PRI | NULL    | auto_increment |
    | order_id            | int(11)      | YES  |     | NULL    |                |
    | vendor_id           | int(11)      | YES  |     | NULL    |                |
    | email               | varchar(255) | YES  |     | NULL    |                |
    | vendor_company_name | varchar(255) | YES  |     | NULL    |                |
    | created_at          | datetime     | YES  |     | NULL    |                |
    | updated_at          | datetime     | YES  |     | NULL    |                |
    +---------------------+--------------+------+-----+---------+----------------+
    
=end
    
    records.each_hash do |row|

      new_record = OrderDropShipEmail.new                  

      new_record.id                 = row["id"].to_i
      new_record.order_id           = row["order_id"].to_i
      new_record.vendor_id          = row["vendor_id"].to_i
      new_record.email              = row["email"]
      new_record.vendor_company_name = "unavailable vendor name"
      new_record.created_at         = Time.parse(row["created_at"])
      new_record.updated_at         = Time.parse(row["updated_at"])
      
      new_record.save(false)
      
    end #end each_hash
    
    puts "\nOrder drop ship email transfer process complete (#{show_time})\n"
    
    
  end #end method transfer_order_drop_ship_emails
  
  
  def destroy_users
    users = User.all
    users.each do |u|
      u.destroy
    end
  end #end method destroy_users
  
  
  def transfer_users
    destroy_users

    records = source_query("select * from users") unless DEMO == true
    records = source_query("select * from users limit 200") unless DEMO == false
    puts "\nBeginning user transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +---------------------------+--------------+------+-----+---------+----------------+
    | Field                     | Type         | Null | Key | Default | Extra          |
    +---------------------------+--------------+------+-----+---------+----------------+
    | id                        | int(11)      | NO   | PRI | NULL    | auto_increment |
    | email                     | varchar(50)  | NO   | MUL | NULL    |                |
    | first_name                | varchar(25)  | NO   | MUL | NULL    |                |
    | last_name                 | varchar(25)  | NO   | MUL | NULL    |                |
    | phone                     | varchar(20)  | YES  |     | NULL    |                |
    | user_type_id              | int(11)      | NO   |     | NULL    |                |
    | user_profile_type_id      | int(11)      | NO   |     | NULL    |                |
    | user_group_id             | int(11)      | NO   |     | NULL    |                |
    | user_status_id            | int(11)      | NO   |     | NULL    |                |
    | last_shipping_profile_id  | int(11)      | YES  |     | NULL    |                |
    | last_billing_profile_id   | int(11)      | YES  |     | NULL    |                |
    | last_dorm_profile_id      | int(11)      | YES  |     | NULL    |                |
    | crypted_password          | varchar(40)  | YES  |     | NULL    |                |
    | salt                      | varchar(40)  | YES  |     | NULL    |                |
    | created_at                | datetime     | YES  |     | NULL    |                |
    | updated_at                | datetime     | YES  |     | NULL    |                |
    | remember_token            | varchar(255) | YES  |     | NULL    |                |
    | remember_token_expires_at | datetime     | YES  |     | NULL    |                |
    +---------------------------+--------------+------+-----+---------+----------------+
    
    NEW
    +---------------------------+--------------+------+-----+---------+----------------+
    | Field                     | Type         | Null | Key | Default | Extra          |
    +---------------------------+--------------+------+-----+---------+----------------+
    | id                        | int(11)      | NO   | PRI | NULL    | auto_increment |
    | email                     | varchar(100) | YES  |     | NULL    |                |
    | crypted_password          | varchar(40)  | YES  |     | NULL    |                |
    | salt                      | varchar(40)  | YES  |     | NULL    |                |
    | created_at                | datetime     | YES  |     | NULL    |                |
    | updated_at                | datetime     | YES  |     | NULL    |                |
    | remember_token            | varchar(40)  | YES  |     | NULL    |                |
    | remember_token_expires_at | datetime     | YES  |     | NULL    |                |
    | first_name                | varchar(255) | YES  |     | NULL    |                |
    | last_name                 | varchar(255) | YES  |     | NULL    |                |
    | phone                     | varchar(255) | YES  |     | NULL    |                |
    +---------------------------+--------------+------+-----+---------+----------------+
    
=end
    
    records.each_hash do |row|

      new_record = User.new                  

      row["created_at"] = "" if row["created_at"] == "0000-00-00 00:00:00"
      row["updated_at"] = "" if row["updated_at"] == "0000-00-00 00:00:00"

      new_record.id                 = row["id"].to_i
      new_record.email              = row["email"]
      new_record.crypted_password   = row["crypted_password"]
      new_record.salt               = row["salt"]
      new_record.created_at         = "#{row["created_at"]}".blank? ? Time.now : Time.parse(row["created_at"])
      new_record.updated_at         = "#{row["updated_at"]}".blank? ? Time.now : Time.parse(row["updated_at"])
      new_record.remember_token     = row["remember_token"]
      new_record.remember_token_expires_at = Time.parse(row["remember_token_expires_at"]) unless row["remember_token_expires_at"].blank?
      new_record.first_name         = row["first_name"]
      new_record.last_name          = row["last_name"]
      new_record.phone              = row["phone"]
      new_record.user_profile_type_id = row["user_profile_type_id"].to_i
      new_record.save(false)
      
    end #end each_hash
    
    puts "\nOrder user transfer process complete (#{show_time})\n"
    
    
  end #end method transfer_users
  
  
  def destroy_users_vendors
    users = User.all
    users.each do |u|
      u.vendor_ids = []
    end
  end #end method destroy_users_vendors
  
  
  def transfer_users_vendors
    destroy_users_vendors
    
    records = source_query("select v.id as vendor_id, vm.user_id as user_id from vendors v, vendor_managers vm, vendor_managers_vendors vmv where vmv.vendor_id = v.id and vmv.vendor_manager_id = vm.id;")
    
    puts "\nBeginning vendor users transfer process (#{show_time}) ....\n"
    
    records.each_hash do |row|

      uid = row["user_id"].to_i
      vid = row["vendor_id"].to_i
      
      begin
        user = User.find(uid)
        user.vendor_ids << vid
      rescue
        puts "Couldn't find a user with ID: #{uid}"
      end
      
    end #end each_hash
    
    puts "\nOrder vendor users transfer process complete (#{show_time})\n"
    
  end #end method transfer_users_vendors
  
  
  def destroy_products
    products = Product.all
    products.each do |p|
      p.destroy
    end
  end #end method destroy_products
  
  
  def transfer_products
    destroy_products
    
    records = source_query("select * from products") unless DEMO == true
    records = source_query("select * from products where id IN (5345,5351,5353,5354,5356,5357,5358,5360,5361,5363,5364,5365,5366,5367,5368,5369,5372,5373,5374,5375,5376,5378,5379,5380,5444);") unless DEMO == false
    
    
    puts "\nBeginning products transfer process (#{show_time}) ....\n"
   
=begin
    ORIGINAL
    +------------------------+--------------+------+-----+---------+----------------+
    | Field                  | Type         | Null | Key | Default | Extra          |
    +------------------------+--------------+------+-----+---------+----------------+
    | id                     | int(11)      | NO   | PRI | NULL    | auto_increment |
    | product_name           | varchar(100) | NO   | MUL | NULL    |                |
    | option_text            | varchar(255) | YES  |     | NULL    |                |
    | product_overview       | text         | NO   |     | NULL    |                |
    | product_details        | text         | YES  |     | NULL    |                |
    | meta_keywords          | text         | NO   |     | NULL    |                |
    | meta_description       | text         | NO   |     | NULL    |                |
    | charge_tax             | tinyint(1)   | YES  |     | 1       |                |
    | new_item               | tinyint(1)   | NO   | MUL | NULL    |                |
    | featured_item          | tinyint(1)   | NO   | MUL | NULL    |                |
    | visible                | tinyint(1)   | YES  | MUL | 1       |                |
    | group_options          | tinyint(1)   | NO   |     | NULL    |                |
    | charge_shipping        | tinyint(1)   | YES  |     | 1       |                |
    | customizable           | tinyint(1)   | NO   |     | NULL    |                |
    | vendor_id              | int(11)      | NO   | MUL | NULL    |                |
    | warehouse_id           | int(11)      | NO   | MUL | NULL    |                |
    | drop_ship              | tinyint(1)   | NO   |     | 0       |                |
    | exclude_from_coupons   | tinyint(1)   | NO   |     | 0       |                |
    | old_product_id         | int(11)      | YES  |     | NULL    |                |
    | az_state               | varchar(255) | YES  |     | NULL    |                |
    | allow_in_gift_registry | tinyint(1)   | YES  |     | 1       |                |
    +------------------------+--------------+------+-----+---------+----------------+
    
    NEW
    +----------------------------+--------------+------+-----+---------+----------------+
    | Field                      | Type         | Null | Key | Default | Extra          |
    +----------------------------+--------------+------+-----+---------+----------------+
    | id                         | int(11)      | NO   | PRI | NULL    | auto_increment |
    | product_name               | varchar(255) | YES  |     | NULL    |                |
    | option_text                | varchar(255) | YES  |     | NULL    |                |
    | product_overview           | text         | YES  |     | NULL    |                |
    | product_details            | text         | YES  |     | NULL    |                |
    | meta_keywords              | text         | YES  |     | NULL    |                |
    | meta_description           | text         | YES  |     | NULL    |                |
    | charge_tax                 | tinyint(1)   | YES  |     | 1       |                |
    | featured_item              | tinyint(1)   | YES  |     | 0       |                |
    | visible                    | tinyint(1)   | YES  |     | 1       |                |
    | charge_shipping            | tinyint(1)   | YES  |     | 1       |                |
    | drop_ship                  | tinyint(1)   | YES  |     | 0       |                |
    | exclude_from_coupons       | tinyint(1)   | YES  |     | 0       |                |
    | allow_in_gift_registry     | tinyint(1)   | YES  |     | 1       |                |
    | created_at                 | datetime     | YES  |     | NULL    |                |
    | updated_at                 | datetime     | YES  |     | NULL    |                |
    | product_image_file_name    | varchar(255) | YES  |     | NULL    |                |
    | product_image_content_type | varchar(255) | YES  |     | NULL    |                |
    | product_image_file_size    | int(11)      | YES  |     | NULL    |                |
    | product_image_updated_at   | datetime     | YES  |     | NULL    |                |
    +----------------------------+--------------+------+-----+---------+----------------+
    
=end
    
    records.each_hash do |row|

      new_record = Product.new                  

      new_record.id                         = row["id"].to_i
      new_record.product_name               = row["product_name"]
      new_record.option_text                = row["option_text"]
      new_record.product_overview           = row["product_overview"]
      new_record.product_details            = row["product_details"]
      new_record.meta_keywords              = row["meta_keywords"]
      new_record.meta_description           = row["meta_description"]
      new_record.charge_tax                 = row["charge_tax"].to_i == 1 ? true : false
      new_record.featured_item              = row["featured_item"].to_i == 1 ? true : false
      new_record.visible                    = row["visible"].to_i == 1 ? true : false
      new_record.charge_shipping            = row["charge_shipping"].to_i == 1 ? true : false
      new_record.drop_ship                  = row["drop_ship"].to_i == 1 ? true : false
      new_record.exclude_from_coupons       = row["exclude_from_coupons"].to_i == 1 ? true : false
      new_record.allow_in_gift_registry     = row["allow_in_gift_registry"].to_i == 1 ? true : false
      new_record.created_at                 = Time.now
      new_record.updated_at                 = Time.now
      new_record.warehouse_ids              = [row["warehouse_id"].to_i]
      new_record.vendor_ids                 = [row["vendor_id"].to_i]
      new_record.skip_all_callbacks         = true
      new_record.save!
      
    end #end each_hash
    
    puts "\nProducts transfer process complete (#{show_time})\n"
    
    
  end #end method transfer_products
  
  
  def transfer_product_images
    
    records = source_query("select p.id, pi.image from products p, product_images pi where pi.product_image_type_id = 1 AND pi.product_id = p.id;") unless DEMO == true
    records = source_query("select p.id, pi.image from products p, product_images pi where pi.product_image_type_id = 1 AND pi.product_id = p.id limit 25;") unless DEMO == false
    
    puts "\nBeginning product image transfer process (#{show_time}) ....\n"
   

    records.each_hash do |row|

      pid = row["id"].to_i
      image_path = row["image"]
      
      path_to_temp = "#{PRODUCT_IMG_PATH}/#{image_path}"
      prod_img_temp = temp_file_from_local(path_to_temp) if File.exists? path_to_temp

      product = Product.find(pid)
      product.product_image = prod_img_temp
      product.save(false)

    end #end each_hash
    
    puts "\nProduct image transfer process complete (#{show_time})\n"
  end #end method transfer_product_images
  
  
  def destroy_additional_product_image_records
    images = AdditionalProductImage.all
    images.each do |i|
      i.destroy
    end
  end #end method destroy_additional_product_image_records
  
  
  def transfer_additional_product_image_records
    destroy_additional_product_image_records
    
=begin
    ORIGINAL
    +---------------+--------------+------+-----+---------+----------------+
    | Field         | Type         | Null | Key | Default | Extra          |
    +---------------+--------------+------+-----+---------+----------------+
    | id            | int(11)      | NO   | PRI | NULL    | auto_increment |
    | product_id    | int(11)      | NO   | MUL | NULL    |                |
    | description   | text         | YES  |     | NULL    |                |
    | display_order | int(11)      | NO   |     | NULL    |                |
    | image         | varchar(255) | NO   |     | NULL    |                |
    | thumb         | varchar(255) | NO   |     | NULL    |                |
    | mini_thumb    | varchar(255) | NO   |     | NULL    |                |
    +---------------+--------------+------+-----+---------+----------------+
    
    NEW
    +--------------------+--------------+------+-----+---------+----------------+
    | Field              | Type         | Null | Key | Default | Extra          |
    +--------------------+--------------+------+-----+---------+----------------+
    | id                 | int(11)      | NO   | PRI | NULL    | auto_increment |
    | description        | varchar(255) | YES  |     | NULL    |                |
    | product_id         | int(11)      | YES  |     | NULL    |                |
    | created_at         | datetime     | YES  |     | NULL    |                |
    | updated_at         | datetime     | YES  |     | NULL    |                |
    | image_file_name    | varchar(255) | YES  |     | NULL    |                |
    | image_content_type | varchar(255) | YES  |     | NULL    |                |
    | image_file_size    | int(11)      | YES  |     | NULL    |                |
    | image_updated_at   | datetime     | YES  |     | NULL    |                |
    +--------------------+--------------+------+-----+---------+----------------+
    
=end


    records = source_query("select api.* from products p, additional_product_images api where api.product_id = p.id AND p.id;") unless DEMO == true
    records = source_query("select api.* from products p, additional_product_images api where api.product_id = p.id AND p.id IN (5345,5351,5353,5354,5356,5357,5358,5360,5361,5363,5364,5365,5366,5367,5368,5369,5372,5373,5374,5375,5376,5378,5379,5380,5444);") unless DEMO == false
    
    
    puts "\nBeginning products transfer process (#{show_time}) ....\n"
   
    
    records.each_hash do |row|

      new_record = AdditionalProductImage.new                  

      new_record.id           = row["id"].to_i
      new_record.description  = row["description"]
      new_record.product_id   = row["product_id"].to_i
      new_record.save(false)  
                              
    end #end each_hash
    
    puts "\nProducts transfer process complete (#{show_time})\n"

    
  end #end method transfer_additional_product_image_records
  
  
  def transfer_additional_product_image_files
    
    records = source_query("select p.id, api.id as 'api_id', api.image from products p, additional_product_images api where api.product_id = p.id AND p.id;") unless DEMO == true
    records = source_query("select p.id, api.id as 'api_id', api.image from products p, additional_product_images api where api.product_id = p.id AND p.id IN (5345,5351,5353,5354,5356,5357,5358,5360,5361,5363,5364,5365,5366,5367,5368,5369,5372,5373,5374,5375,5376,5378,5379,5380,5444);") unless DEMO == false
    
    puts "\nBeginning additional product image file transfer process (#{show_time}) ....\n"
   

    records.each_hash do |row|

      pid = row["id"].to_i
      api_id = row["api_id"].to_i
      image_path = row["image"]
      
      path_to_temp = "#{PRODUCT_IMG_PATH}/#{image_path}"
      img_temp = temp_file_from_local(path_to_temp) if File.exists? path_to_temp

      api = AdditionalProductImage.find(api_id)
      api.image = img_temp
      api.save(false)

    end #end each_hash
    
    puts "\nProduct additional image file transfer process complete (#{show_time})\n"
  
  
  end #end method transfer_additional_product_image_files
  
  
  def destroy_product_variations
    variations = ProductVariation.all
    variations.each do |v|
      v.destroy
    end
  end #end method destroy_product_variations
  
  
  def transfer_product_variations
    destroy_product_variations
    
    records = source_query("select v.* from products p, product_variations v where v.product_id = p.id AND p.id;") unless DEMO == true
    records = source_query("select v.* from products p, product_variations v where v.product_id = p.id AND p.id IN (5345,5351,5353,5354,5356,5357,5358,5360,5361,5363,5364,5365,5366,5367,5368,5369,5372,5373,5374,5375,5376,5378,5379,5380,5444);") unless DEMO == false
    
    
    puts "\nBeginning products variations transfer process (#{show_time}) ....\n"
    
=begin
    ORIGINAL
    +-------------------------+---------------+------+-----+---------+----------------+
    | Field                   | Type          | Null | Key | Default | Extra          |
    +-------------------------+---------------+------+-----+---------+----------------+
    | id                      | int(11)       | NO   | PRI | NULL    | auto_increment |
    | product_id              | int(11)       | YES  |     | NULL    |                |
    | title                   | varchar(255)  | YES  |     | NULL    |                |
    | int_retail_price        | int(11)       | YES  |     | 0       |                |
    | int_current_price       | int(11)       | YES  |     | 0       |                |
    | qty_on_hand             | int(11)       | YES  |     | NULL    |                |
    | qty_on_hold             | int(11)       | YES  |     | NULL    |                |
    | product_number          | varchar(255)  | YES  |     | NULL    |                |
    | manufacturer_number     | varchar(255)  | YES  |     | NULL    |                |
    | int_integrated_shipping | int(11)       | YES  |     | 0       |                |
    | int_fixed_shipping      | int(11)       | YES  |     | 0       |                |
    | visible                 | tinyint(1)    | YES  |     | 1       |                |
    | variation_group         | varchar(255)  | YES  |     | NULL    |                |
    | sold_count              | int(11)       | YES  |     | 0       |                |
    | wh_row                  | varchar(5)    | YES  |     | NULL    |                |
    | wh_bay                  | varchar(5)    | YES  |     | NULL    |                |
    | wh_shelf                | varchar(5)    | YES  |     | NULL    |                |
    | wh_product              | varchar(5)    | YES  |     | NULL    |                |
    | az_state                | varchar(255)  | YES  |     | NULL    |                |
    | standard_product        | varchar(255)  | YES  |     | NULL    |                |
    | standard_product_type   | varchar(255)  | YES  |     | NULL    |                |
    | upc                     | varchar(50)   | YES  |     | NULL    |                |
    | reorder_qty             | int(11)       | YES  |     | 0       |                |
    | temp_on_hand            | int(11)       | YES  |     | NULL    |                |
    | int_wholesale_price     | int(11)       | YES  |     | 0       |                |
    | int_freight_in_price    | int(11)       | YES  |     | 0       |                |
    | int_drop_ship_fee_price | int(11)       | YES  |     | 0       |                |
    | markup                  | decimal(10,0) | YES  |     | NULL    |                |
    | int_shipping_in_price   | int(11)       | YES  |     | 0       |                |
    | int_list_price          | int(11)       | YES  |     | 0       |                |
    +-------------------------+---------------+------+-----+---------+----------------+
    
    NEW
    +-----------------------+--------------+------+-----+---------+----------------+
    | Field                 | Type         | Null | Key | Default | Extra          |
    +-----------------------+--------------+------+-----+---------+----------------+
    | id                    | int(11)      | NO   | PRI | NULL    | auto_increment |
    | product_id            | int(11)      | YES  |     | NULL    |                |
    | title                 | varchar(255) | YES  |     | NULL    |                |
    | qty_on_hand           | int(11)      | YES  |     | 0       |                |
    | qty_on_hold           | int(11)      | YES  |     | 0       |                |
    | reorder_qty           | int(11)      | YES  |     | 0       |                |
    | int_wholesale_price   | int(11)      | YES  |     | 0       |                |
    | int_freight_in_price  | int(11)      | YES  |     | 0       |                |
    | int_drop_ship_fee     | int(11)      | YES  |     | 0       |                |
    | int_shipping_in_price | int(11)      | YES  |     | 0       |                |
    | markup                | decimal(6,3) | YES  |     | NULL    |                |
    | int_list_price        | int(11)      | YES  |     | 0       |                |
    | variation_group       | varchar(255) | YES  |     | NULL    |                |
    | product_number        | varchar(255) | YES  |     | NULL    |                |
    | manufacturer_number   | varchar(255) | YES  |     | NULL    |                |
    | visible               | tinyint(1)   | YES  |     | 1       |                |
    | wh_row                | varchar(5)   | YES  |     | NULL    |                |
    | wh_bay                | varchar(5)   | YES  |     | NULL    |                |
    | wh_shelf              | varchar(5)   | YES  |     | NULL    |                |
    | wh_product            | varchar(5)   | YES  |     | NULL    |                |
    | created_at            | datetime     | YES  |     | NULL    |                |
    | updated_at            | datetime     | YES  |     | NULL    |                |
    | sold_count            | int(11)      | YES  |     | 0       |                |
    +-----------------------+--------------+------+-----+---------+----------------+
    
=end
    
    records.each_hash do |row|

      new_record = ProductVariation.new                  

      new_record.id                    = row["id"].to_i
      new_record.product_id            = row["product_id"]
      new_record.title                 = row["title"]
      new_record.qty_on_hand           = row["qty_on_hand"].to_i
      new_record.qty_on_hold           = row["qty_on_hold"].to_i
      new_record.reorder_qty           = row["reorder_qty"].to_i
      new_record.int_wholesale_price   = row["int_wholesale_price"].to_i
      new_record.int_freight_in_price  = row["int_freight_in_price"].to_i
      new_record.int_drop_ship_fee     = row["int_drop_ship_fee"].to_i
      new_record.int_shipping_in_price = row["int_shipping_in_price"].to_i
      new_record.markup                = row["markup"].to_d unless row["markup"].blank?
      new_record.int_list_price        = row["int_list_price"].to_i
      new_record.variation_group       = row["variation_group"]
      new_record.product_number        = row["product_number"]
      new_record.manufacturer_number   = row["manufacturer_number"]
      new_record.visible               = row["visible"].to_i == 1 ? true : false
      new_record.wh_row                = row["wh_row"]
      new_record.wh_bay                = row["wh_bay"]
      new_record.wh_shelf              = row["wh_shelf"]
      new_record.wh_product            = row["wh_product"]
      new_record.sold_count            = row["sold_count"].to_i
    
      new_record.save(false)  
                              
    end #end each_hash
    
    puts "\nProducts variations transfer process complete (#{show_time})\n"
    
    
  end #end method transfer_product_variations
  
  
  def destroy_product_packages
    packages = ProductPackage.all
    packages.each do |p|
      p.destroy
    end
  end #end method destroy_product_packages
  
  
  def transfer_product_packages
    destroy_product_packages
    
    records = source_query("select pp.* from product_packages pp, product_variations pv, products p where pp.product_variation_id = pv.id AND pv.product_id = p.id;") unless DEMO == true
    records = source_query("select pp.* from product_packages pp, product_variations pv, products p where pp.product_variation_id = pv.id AND pv.product_id = p.id AND p.id IN (5345,5351,5353,5354,5356,5357,5358,5360,5361,5363,5364,5365,5366,5367,5368,5369,5372,5373,5374,5375,5376,5378,5379,5380,5444);") unless DEMO == false
    
    
    puts "\nBeginning product packages transfer process (#{show_time}) ....\n"
    
=begin
    ORIGINAL
    +----------------------+------------+------+-----+---------+----------------+
    | Field                | Type       | Null | Key | Default | Extra          |
    +----------------------+------------+------+-----+---------+----------------+
    | id                   | int(11)    | NO   | PRI | NULL    | auto_increment |
    | product_id           | int(11)    | NO   | MUL | NULL    |                |
    | weight               | float      | NO   |     | NULL    |                |
    | length               | float      | NO   |     | NULL    |                |
    | width                | float      | NO   |     | NULL    |                |
    | depth                | float      | NO   |     | NULL    |                |
    | ships_separately     | tinyint(1) | NO   |     | NULL    |                |
    | product_variation_id | int(11)    | YES  |     | NULL    |                |
    +----------------------+------------+------+-----+---------+----------------+
    
    NEW
    +----------------------+--------------+------+-----+---------+----------------+
    | Field                | Type         | Null | Key | Default | Extra          |
    +----------------------+--------------+------+-----+---------+----------------+
    | id                   | int(11)      | NO   | PRI | NULL    | auto_increment |
    | weight               | decimal(6,3) | YES  |     | NULL    |                |
    | length               | decimal(6,3) | YES  |     | NULL    |                |
    | width                | decimal(6,3) | YES  |     | NULL    |                |
    | depth                | decimal(6,3) | YES  |     | NULL    |                |
    | ships_separately     | tinyint(1)   | YES  |     | 0       |                |
    | product_variation_id | int(11)      | YES  |     | NULL    |                |
    | created_at           | datetime     | YES  |     | NULL    |                |
    | updated_at           | datetime     | YES  |     | NULL    |                |
    +----------------------+--------------+------+-----+---------+----------------+
=end
    
    records.each_hash do |row|

      new_record = ProductPackage.new                  

      new_record.id                   = row["id"].to_i
      new_record.weight               = row["weight"].to_f.to_d
      new_record.length               = row["length"].to_f.to_d
      new_record.width                = row["width"].to_f.to_d
      new_record.depth                = row["depth"].to_f.to_d
      new_record.ships_separately     = row["ships_separately"].to_i == 1 ? true : false
      new_record.product_variation_id = row["product_variation_id"].to_i

      new_record.save(false)  
                              
    end #end each_hash
    
    puts "\nProduct packages transfer process complete (#{show_time})\n"
    
  end #end method transfer_product_packages
  
  def destroy_addresses
    addresses = Address.all
    addresses.each do |a|
      a.destroy
    end
  end #end method destroy_addresses
  
  
  def transfer_addresses
    destroy_addresses
    
    puts "\nBeginning user address transfer process (#{show_time}) ....\n"
    
    
    
    shipping_records = source_query("select distinct u.user_profile_type_id, x.* from shipping_profiles x, users u where x.user_id = u.id;")
    
    shipping_records.each_hash do |row|

      u = User.find(row["user_id"].to_i) rescue nil
      
      if u
        
        u.shipping_phone             = row["phone"]
        u.shipping_country_id        = row["country_id"].to_i
        u.shipping_zipcode           = row["zipcode"]
        u.shipping_state_id          = row["state_id"].to_i
        u.shipping_city              = row["city"]
        u.shipping_address2          = row["address2"]
        u.shipping_address           = row["address"]
        u.shipping_last_name         = row["last_name"]
        u.shipping_first_name        = row["first_name"]
        
        u.save(false)
        
      end
                              
    end #end each_hash
    
    
    
    
    billing_records = source_query("select distinct u.user_profile_type_id, x.* from billing_profiles x, users u where x.user_id = u.id;")
    
    billing_records.each_hash do |row|

      u = User.find(row["user_id"].to_i) rescue nil
      
      if u

        u.billing_phone              = row["phone"]
        u.billing_country_id         = row["country_id"].to_i
        u.billing_zipcode            = row["zipcode"]
        u.billing_state_id           = row["state_id"].to_i
        u.billing_city               = row["city"]
        u.billing_address2           = row["address2"]
        u.billing_address            = row["address"]
        u.billing_last_name          = row["last_name"]
        u.billing_first_name         = row["first_name"]
        
        u.save(false)
        
      end
                              
    end #end each_hash
    
    
    
    
    dorm_records = source_query("select distinct u.user_profile_type_id, x.* from dorm_shipping_profiles x, users u where x.user_id = u.id;")
    
    dorm_records.each_hash do |row|

      u = User.find(row["user_id"].to_i) rescue nil
      
      if u
        
         u.billing_phone
         u.dorm_ship_not_part         = row["not_part"].to_i == 1 ? true : false
         u.dorm_ship_not_assigned     = row["not_assigned"].to_i == 1 ? true : false
         u.dorm_ship_college_name     = row["college_name"]
         u.shipping_phone             = row["phone"]
         u.shipping_country_id        = row["country_id"].to_i
         u.shipping_zipcode           = row["zipcode"]
         u.shipping_state_id          = row["state_id"].to_i
         u.shipping_city              = row["city"]
         u.shipping_address2          = row["address2"]
         u.shipping_address           = row["address"]
         u.shipping_last_name         = row["last_name"]
         u.shipping_first_name        = row["first_name"]
        
         u.save(false)
      end
                              
    end #end each_hash
    
    
    
    
    puts "\nUser address transfer process complete (#{show_time})\n"
    
    
  end #end method transfer_addresses
  
  
  
  
end #end class