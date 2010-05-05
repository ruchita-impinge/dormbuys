class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :order_id
      t.datetime :order_date
      t.integer :user_id
      t.integer :user_profile_type_id
      t.string :billing_first_name
      t.string :billing_last_name
      t.string :billing_address
      t.string :billing_address2
      t.string :billing_city
      t.integer :billing_state_id
      t.string :billing_zipcode
      t.integer :billing_country_id
      t.string :shipping_first_name
      t.string :shipping_last_name
      t.string :shipping_address
      t.string :shipping_address2
      t.string :shipping_city
      t.integer :shipping_state_id
      t.string :shipping_zipcode
      t.integer :shipping_country_id
      t.string :shipping_phone
      t.string :dorm_ship_college_name
      t.boolean :dorm_ship_not_assigned
      t.boolean :dorm_ship_not_part
      t.integer :dorm_ship_time_id
      t.date :dorm_ship_ship_date
      t.integer :order_status_id, :default => 1
      t.text :order_comments
      t.integer :payment_provider_id
      t.string :payment_transaction_number
      t.string :client_ip_address
      t.integer :coupon_id
      t.integer :how_heard_option_id
      t.string :how_heard_option_value
      t.text :packing_configuration
      t.string :billing_phone
      t.string :email
      t.boolean :processed, :default => false
      t.boolean :processing, :default => false
      t.integer :int_total_giftcards, :default => 0
      t.integer :int_total_coupon, :default => 0
      t.integer :int_total_discounts, :default => 0
      t.integer :int_subtotal, :default => 0
      t.integer :int_tax, :default => 0
      t.integer :int_shipping, :default => 0
      t.integer :int_grand_total, :default => 0
      t.string :whoami

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
