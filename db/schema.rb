# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120109154424) do

  create_table "additional_product_images", :force => true do |t|
    t.string   "description"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "addresses", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zip"
    t.integer  "country_id"
    t.string   "phone"
    t.string   "dorm_ship_college_name"
    t.boolean  "dorm_ship_not_assigned"
    t.boolean  "dorm_ship_not_part"
    t.integer  "address_type_id"
    t.boolean  "default_billing",        :default => false
    t.boolean  "default_shipping",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_scrapes", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands_products", :id => false, :force => true do |t|
    t.integer "brand_id"
    t.integer "product_id"
  end

  add_index "brands_products", ["brand_id"], :name => "index_brands_products_on_brand_id"
  add_index "brands_products", ["product_id"], :name => "index_brands_products_on_product_id"

  create_table "brands_vendors", :id => false, :force => true do |t|
    t.integer "brand_id"
    t.integer "vendor_id"
  end

  add_index "brands_vendors", ["brand_id"], :name => "index_brands_vendors_on_brand_id"
  add_index "brands_vendors", ["vendor_id"], :name => "index_brands_vendors_on_vendor_id"

  create_table "cart_items", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "product_variation_id"
    t.integer  "quantity"
    t.string   "product_option_values"
    t.string   "product_as_option_values"
    t.integer  "int_unit_price",           :default => 0
    t.integer  "int_total_price",          :default => 0
    t.boolean  "is_gift_registry_item",    :default => false
    t.boolean  "is_wish_list_item",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "int_discount_value",       :default => 0
    t.integer  "wish_list_item_id"
    t.integer  "gift_registry_item_id"
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "user_profile_type_id",   :default => 1
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "billing_address"
    t.string   "billing_address2"
    t.string   "billing_city"
    t.integer  "billing_state_id"
    t.string   "billing_zipcode"
    t.integer  "billing_country_id"
    t.string   "shipping_first_name"
    t.string   "shipping_last_name"
    t.string   "shipping_address"
    t.string   "shipping_address2"
    t.string   "shipping_city"
    t.integer  "shipping_state_id"
    t.string   "shipping_zipcode"
    t.integer  "shipping_country_id"
    t.string   "shipping_phone"
    t.string   "dorm_ship_college_name"
    t.boolean  "dorm_ship_not_assigned"
    t.boolean  "dorm_ship_not_part"
    t.integer  "dorm_ship_time_id"
    t.date     "dorm_ship_ship_date"
    t.integer  "payment_provider_id",    :default => 1
    t.string   "client_ip_address"
    t.integer  "coupon_id"
    t.integer  "how_heard_option_id"
    t.string   "how_heard_option_value"
    t.string   "billing_phone"
    t.string   "email"
    t.string   "whoami"
    t.binary   "payment_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salt"
  end

  create_table "carts_gift_cards", :id => false, :force => true do |t|
    t.integer "cart_id"
    t.integer "gift_card_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "keywords"
    t.boolean  "visible",                     :default => true
    t.integer  "display_order",               :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "banner_file_name"
    t.string   "banner_content_type"
    t.integer  "banner_file_size"
    t.datetime "banner_updated_at"
    t.string   "featured_image_file_name"
    t.string   "featured_image_content_type"
    t.integer  "featured_image_file_size"
    t.datetime "featured_image_updated_at"
    t.string   "permalink_handle"
  end

  add_index "categories", ["permalink_handle"], :name => "index_categories_on_permalink_handle"

  create_table "contact_messages", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string   "country_name"
    t.string   "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ship_to_enabled", :default => false
  end

  create_table "coupon_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupons", :force => true do |t|
    t.string   "coupon_number"
    t.boolean  "expires",          :default => true
    t.date     "expiration_date"
    t.boolean  "reusable",         :default => true
    t.boolean  "used",             :default => false
    t.string   "description"
    t.integer  "int_min_purchase", :default => 0
    t.integer  "int_value",        :default => 0
    t.integer  "coupon_type_id"
    t.boolean  "is_free_shipping", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tier_rules"
  end

  create_table "couriers", :force => true do |t|
    t.string   "courier_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "daily_dorm_deal_email_subscribers", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "daily_dorm_deals", :force => true do |t|
    t.datetime "start_time"
    t.integer  "type_id"
    t.integer  "product_id"
    t.integer  "product_variation_id"
    t.string   "title"
    t.text     "description"
    t.integer  "initial_qty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "end_time"
    t.integer  "int_original_price",   :default => 0
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "destinations", :force => true do |t|
    t.string   "postal_code"
    t.string   "state_province"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dorm_bucks_email_list_clients", :force => true do |t|
    t.string "email"
  end

  create_table "email_list_clients", :force => true do |t|
    t.string "email"
  end

  create_table "gift_card_reports", :force => true do |t|
    t.text     "csv_data"
    t.integer  "valid_count"
    t.integer  "valid_total"
    t.integer  "all_count"
    t.integer  "all_total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gift_cards", :force => true do |t|
    t.string   "giftcard_number"
    t.string   "giftcard_pin"
    t.integer  "int_current_amount",  :default => 0
    t.integer  "int_original_amount", :default => 0
    t.boolean  "expires"
    t.date     "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gift_cards_orders", :id => false, :force => true do |t|
    t.integer "gift_card_id"
    t.integer "order_id"
  end

  add_index "gift_cards_orders", ["gift_card_id"], :name => "index_gift_cards_orders_on_gift_card_id"
  add_index "gift_cards_orders", ["order_id"], :name => "index_gift_cards_orders_on_order_id"

  create_table "gift_registries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "registry_reason_id"
    t.integer  "registry_for_id"
    t.string   "title"
    t.text     "message"
    t.date     "event_date"
    t.string   "shipping_address"
    t.string   "shipping_address2"
    t.string   "shipping_city"
    t.integer  "shipping_state_id"
    t.string   "shipping_zip_code"
    t.integer  "shipping_country_id"
    t.string   "shipping_phone"
    t.string   "registry_number"
    t.boolean  "show_in_search_by_name",   :default => true
    t.boolean  "show_in_search_by_number", :default => true
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "gift_registry_items", :force => true do |t|
    t.integer "gift_registry_id"
    t.integer "product_variation_id"
    t.integer "desired_qty"
    t.integer "received_qty"
    t.text    "comments"
    t.string  "product_option_values"
    t.string  "product_as_option_values"
    t.text    "product_custom_option_values"
  end

  create_table "gift_registry_names", :force => true do |t|
    t.integer "gift_registry_id"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
  end

  create_table "home_banners", :force => true do |t|
    t.boolean  "is_main"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "order_drop_ship_emails", :force => true do |t|
    t.integer  "order_id"
    t.integer  "vendor_id"
    t.string   "email"
    t.string   "vendor_company_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_line_item_discounts", :force => true do |t|
    t.integer "order_line_item_id",                                :null => false
    t.string  "discount_message",    :limit => 100
    t.integer "int_discount_amount",                :default => 0
  end

  add_index "order_line_item_discounts", ["order_line_item_id"], :name => "index_order_line_item_discounts_on_order_line_item_id"

  create_table "order_line_item_options", :force => true do |t|
    t.integer  "order_line_item_id"
    t.string   "option_name"
    t.string   "option_value"
    t.decimal  "weight_increase",    :precision => 6, :scale => 3, :default => 0.0
    t.integer  "int_price_increase",                               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_line_item_product_as_options", :force => true do |t|
    t.integer  "order_line_item_id"
    t.string   "option_name"
    t.string   "display_value"
    t.integer  "int_price",          :default => 0
    t.string   "product_name"
    t.string   "product_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_line_items", :force => true do |t|
    t.integer  "order_id"
    t.string   "item_name"
    t.integer  "quantity"
    t.string   "vendor_company_name"
    t.string   "product_manufacturer_number"
    t.string   "product_number"
    t.integer  "int_unit_price",              :default => 0
    t.integer  "int_total",                   :default => 0
    t.boolean  "product_drop_ship"
    t.string   "warehouse_location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wish_list_item_id"
    t.integer  "gift_registry_item_id"
  end

  create_table "order_vendors", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zip_code"
    t.integer  "country_id"
    t.string   "customer_service_phone"
    t.string   "customer_service_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "website"
  end

  create_table "orders", :force => true do |t|
    t.string   "order_id"
    t.datetime "order_date"
    t.integer  "user_id"
    t.integer  "user_profile_type_id"
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "billing_address"
    t.string   "billing_address2"
    t.string   "billing_city"
    t.integer  "billing_state_id"
    t.string   "billing_zipcode"
    t.integer  "billing_country_id"
    t.string   "shipping_first_name"
    t.string   "shipping_last_name"
    t.string   "shipping_address"
    t.string   "shipping_address2"
    t.string   "shipping_city"
    t.integer  "shipping_state_id"
    t.string   "shipping_zipcode"
    t.integer  "shipping_country_id"
    t.string   "shipping_phone"
    t.string   "dorm_ship_college_name"
    t.boolean  "dorm_ship_not_assigned"
    t.boolean  "dorm_ship_not_part"
    t.integer  "dorm_ship_time_id"
    t.date     "dorm_ship_ship_date"
    t.integer  "order_status_id",            :default => 1
    t.text     "order_comments"
    t.integer  "payment_provider_id"
    t.string   "payment_transaction_number"
    t.string   "client_ip_address"
    t.integer  "coupon_id"
    t.integer  "how_heard_option_id"
    t.string   "how_heard_option_value"
    t.text     "packing_configuration"
    t.string   "billing_phone"
    t.string   "email"
    t.boolean  "processed",                  :default => false
    t.boolean  "processing",                 :default => false
    t.integer  "int_total_giftcards",        :default => 0
    t.integer  "int_total_coupon",           :default => 0
    t.integer  "int_total_discounts",        :default => 0
    t.integer  "int_subtotal",               :default => 0
    t.integer  "int_tax",                    :default => 0
    t.integer  "int_shipping",               :default => 0
    t.integer  "int_grand_total",            :default => 0
    t.string   "whoami"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_vendor_id"
    t.text     "payment_transaction_data"
    t.boolean  "sent_to_packstream",         :default => false
    t.integer  "cart_id"
  end

  create_table "orders_vendors", :id => false, :force => true do |t|
    t.integer "order_id"
    t.integer "vendor_id"
  end

  create_table "product_as_option_values", :force => true do |t|
    t.integer  "product_variation_id"
    t.integer  "product_as_option_id"
    t.string   "display_value"
    t.integer  "int_price_adjustment", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_as_options", :force => true do |t|
    t.integer "product_id",                :null => false
    t.string  "option_name", :limit => 50, :null => false
  end

  add_index "product_as_options", ["product_id"], :name => "index_product_as_options_on_product_id"

  create_table "product_option_values", :force => true do |t|
    t.integer "product_option_id",                                 :null => false
    t.string  "option_value",       :limit => 50,                  :null => false
    t.float   "weight_increase",                  :default => 0.0, :null => false
    t.integer "display_order",                    :default => 0,   :null => false
    t.integer "int_price_increase",               :default => 0
  end

  add_index "product_option_values", ["product_option_id"], :name => "index_product_option_values_on_product_option_id"

  create_table "product_options", :force => true do |t|
    t.integer "product_id",                :null => false
    t.string  "option_name", :limit => 50, :null => false
  end

  add_index "product_options", ["product_id"], :name => "index_product_options_on_product_id"

  create_table "product_packages", :force => true do |t|
    t.decimal  "weight",               :precision => 6, :scale => 3
    t.decimal  "length",               :precision => 6, :scale => 3
    t.decimal  "width",                :precision => 6, :scale => 3
    t.decimal  "depth",                :precision => 6, :scale => 3
    t.boolean  "ships_separately",                                   :default => false
    t.integer  "product_variation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_restrictions", :force => true do |t|
    t.integer "product_id"
    t.integer "state_id"
    t.string  "description"
  end

  create_table "product_variations", :force => true do |t|
    t.integer  "product_id"
    t.string   "title"
    t.integer  "qty_on_hand",                                                          :default => 0
    t.integer  "qty_on_hold",                                                          :default => 0
    t.integer  "reorder_qty",                                                          :default => 0
    t.integer  "int_wholesale_price",                                                  :default => 0
    t.integer  "int_freight_in_price",                                                 :default => 0
    t.integer  "int_drop_ship_fee",                                                    :default => 0
    t.integer  "int_shipping_in_price",                                                :default => 0
    t.decimal  "markup",                                 :precision => 6, :scale => 3
    t.integer  "int_list_price",                                                       :default => 0
    t.string   "variation_group"
    t.string   "product_number"
    t.string   "manufacturer_number"
    t.boolean  "visible",                                                              :default => true
    t.string   "wh_row",                    :limit => 5
    t.string   "wh_bay",                    :limit => 5
    t.string   "wh_shelf",                  :limit => 5
    t.string   "wh_product",                :limit => 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sold_count",                                                           :default => 0
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "upc"
    t.string   "sears_variation_name"
    t.string   "sears_variation_attribute"
    t.boolean  "was_posted_to_sears",                                                  :default => false
  end

  create_table "product_variations_quantity_discounts", :id => false, :force => true do |t|
    t.integer "product_variation_id"
    t.integer "quantity_discount_id"
  end

  create_table "products", :force => true do |t|
    t.string   "product_name"
    t.string   "option_text"
    t.text     "product_overview"
    t.text     "meta_keywords"
    t.text     "meta_description"
    t.boolean  "charge_tax",                 :default => true
    t.boolean  "featured_item",              :default => false
    t.boolean  "visible",                    :default => true
    t.boolean  "charge_shipping",            :default => true
    t.boolean  "drop_ship",                  :default => false
    t.boolean  "exclude_from_coupons",       :default => false
    t.boolean  "allow_in_gift_registry",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "product_image_file_name"
    t.string   "product_image_content_type"
    t.integer  "product_image_file_size"
    t.datetime "product_image_updated_at"
    t.string   "permalink_handle"
    t.text     "description_general"
    t.boolean  "include_in_feeds",           :default => true
    t.integer  "primary_subcategory_id"
    t.boolean  "should_list_on_sears",       :default => false
    t.datetime "posted_to_sears_at"
  end

  add_index "products", ["permalink_handle"], :name => "index_products_on_permalink_handle"

  create_table "products_subcategories", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "subcategory_id"
  end

  add_index "products_subcategories", ["product_id"], :name => "index_products_subcategories_on_product_id"
  add_index "products_subcategories", ["subcategory_id"], :name => "index_products_subcategories_on_subcategory_id"

  create_table "products_vendors", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "vendor_id"
  end

  create_table "products_warehouses", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "warehouse_id"
  end

  create_table "quantity_discounts", :force => true do |t|
    t.integer  "discount_type", :default => 0
    t.integer  "each_next",     :default => 0
    t.integer  "buy_qty",       :default => 1
    t.integer  "next_qty",      :default => 1
    t.string   "message"
    t.integer  "int_value",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "refunds", :force => true do |t|
    t.integer  "order_id",                      :null => false
    t.string   "transaction_id",                :null => false
    t.integer  "user_id",                       :null => false
    t.string   "response_data",                 :null => false
    t.string   "message",                       :null => false
    t.boolean  "success",                       :null => false
    t.datetime "created_at"
    t.integer  "int_amount",     :default => 0
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "sears_transmissions", :force => true do |t|
    t.datetime "sent_at"
    t.text     "variations"
    t.text     "description"
    t.boolean  "sync_inventory"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_containers", :force => true do |t|
    t.string  "title",              :limit => 100,                    :null => false
    t.float   "length",                                               :null => false
    t.float   "width",                                                :null => false
    t.float   "depth",                                                :null => false
    t.float   "weight",                                               :null => false
    t.integer "qty_onhand",                                           :null => false
    t.boolean "dimensional_weight",                :default => false, :null => false
  end

  create_table "shipping_labels", :force => true do |t|
    t.integer "order_id",                             :null => false
    t.string  "tracking_number",       :limit => 100, :null => false
    t.string  "label",                                :null => false
    t.string  "identification_number"
  end

  add_index "shipping_labels", ["order_id"], :name => "index_shipping_labels_on_order_id"

  create_table "shipping_numbers", :force => true do |t|
    t.string   "qty_description",    :limit => 25, :null => false
    t.string   "tracking_number",    :limit => 50
    t.integer  "courier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_line_item_id",               :null => false
  end

  create_table "shipping_rates", :force => true do |t|
    t.integer "int_subtotal",            :default => 0
    t.integer "int_standard_rate",       :default => 0
    t.integer "int_express_rate",        :default => 0
    t.integer "int_overnight_rate",      :default => 0
    t.integer "shipping_rates_table_id"
  end

  create_table "shipping_rates_tables", :force => true do |t|
    t.boolean "enabled", :default => false
  end

  create_table "state_shipping_rates", :force => true do |t|
    t.integer  "state_id"
    t.integer  "int_additional_cost", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "abbreviation"
    t.string   "full_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subcategories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "keywords"
    t.integer  "category_id"
    t.integer  "parent_id"
    t.boolean  "visible",                 :default => true
    t.integer  "display_order",           :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "list_image_file_name"
    t.string   "list_image_content_type"
    t.integer  "list_image_file_size"
    t.datetime "list_image_updated_at"
    t.string   "permalink_handle"
  end

  add_index "subcategories", ["permalink_handle"], :name => "index_subcategories_on_permalink_handle"

  create_table "subcategories_third_party_categories", :id => false, :force => true do |t|
    t.integer "subcategory_id"
    t.integer "third_party_category_id"
  end

  create_table "third_party_categories", :force => true do |t|
    t.string   "name"
    t.string   "owner"
    t.string   "parent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",                    :default => 0
    t.string   "data"
    t.string   "tree"
    t.datetime "attributes_popuplated_at"
  end

  add_index "third_party_categories", ["owner"], :name => "index_third_party_categories_on_owner"

  create_table "third_party_variation_attributes", :force => true do |t|
    t.integer  "third_party_variation_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "third_party_variations", :force => true do |t|
    t.string   "owner"
    t.integer  "third_party_category_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.integer  "user_profile_type_id",                     :default => 1
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "billing_address"
    t.string   "billing_address2"
    t.string   "billing_city"
    t.integer  "billing_state_id"
    t.string   "billing_zipcode"
    t.integer  "billing_country_id"
    t.string   "shipping_first_name"
    t.string   "shipping_last_name"
    t.string   "shipping_address"
    t.string   "shipping_address2"
    t.string   "shipping_city"
    t.integer  "shipping_state_id"
    t.string   "shipping_zipcode"
    t.integer  "shipping_country_id"
    t.string   "shipping_phone"
    t.string   "dorm_ship_college_name"
    t.boolean  "dorm_ship_not_assigned"
    t.boolean  "dorm_ship_not_part"
    t.string   "billing_phone"
    t.string   "whoami"
  end

  create_table "users_vendors", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "vendor_id"
  end

  create_table "vendors", :force => true do |t|
    t.string  "account_number",     :limit => 30,                   :null => false
    t.string  "company_name",       :limit => 30,                   :null => false
    t.string  "address",            :limit => 60,                   :null => false
    t.string  "address2",           :limit => 60
    t.string  "city",               :limit => 30,                   :null => false
    t.integer "state_id",                                           :null => false
    t.string  "zipcode",            :limit => 20,                   :null => false
    t.integer "country_id",                                         :null => false
    t.string  "phone",              :limit => 20,                   :null => false
    t.boolean "dropship",                         :default => true, :null => false
    t.boolean "enabled",                          :default => true, :null => false
    t.string  "corporate_name",     :limit => 75
    t.string  "fax",                :limit => 20
    t.string  "website"
    t.string  "billing_address",    :limit => 75
    t.string  "billing_address2",   :limit => 75
    t.string  "billing_city",       :limit => 50
    t.integer "billing_state_id"
    t.string  "billing_zipcode",    :limit => 15
    t.integer "billing_country_id"
    t.string  "contact_name"
    t.text    "notes"
  end

  add_index "vendors", ["account_number"], :name => "index_vendors_on_account_number"
  add_index "vendors", ["company_name"], :name => "index_vendors_on_company_name"

  create_table "warehouses", :force => true do |t|
    t.integer "vendor_id",                :null => false
    t.string  "name",       :limit => 75, :null => false
    t.string  "address",    :limit => 50, :null => false
    t.string  "address2",   :limit => 50
    t.string  "city",       :limit => 50, :null => false
    t.integer "state_id",                 :null => false
    t.string  "zipcode",    :limit => 20, :null => false
    t.integer "country_id",               :null => false
  end

  create_table "wish_list_items", :force => true do |t|
    t.integer  "wish_list_id"
    t.integer  "product_variation_id"
    t.integer  "wish_qty"
    t.integer  "got_qty"
    t.text     "comments"
    t.text     "product_option_values"
    t.text     "product_as_option_values"
    t.text     "product_custom_option_values"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wish_lists", :force => true do |t|
    t.integer  "user_id"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "wrap_up_america_sales", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "quantity"
    t.string   "campus"
    t.string   "team"
    t.integer  "cart_item_id"
    t.boolean  "purchase_confirmed", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
