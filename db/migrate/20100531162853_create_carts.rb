class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
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
      t.date :dorm_ship_date
      t.integer :payment_provider_id
      t.string :client_ip_address
      t.integer :coupon_id
      t.integer :how_heard_option_id
      t.string :how_heard_option_value
      t.string :billing_phone
      t.string :email
      t.string :whoami
      t.text :payment_data

      t.timestamps
    end
  end

  def self.down
    drop_table :carts
  end
end
