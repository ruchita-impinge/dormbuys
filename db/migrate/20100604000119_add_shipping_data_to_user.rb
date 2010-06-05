class AddShippingDataToUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :user_shipping_type_id, :user_profile_type_id
    change_column_default :users, :user_profile_type_id, 1
    add_column :users, :billing_first_name, :string
    add_column :users, :billing_last_name, :string
    add_column :users, :billing_address, :string
    add_column :users, :billing_address2, :string
    add_column :users, :billing_city, :string
    add_column :users, :billing_state_id, :integer
    add_column :users, :billing_zipcode, :string
    add_column :users, :billing_country_id, :integer
    add_column :users, :shipping_first_name, :string
    add_column :users, :shipping_last_name, :string
    add_column :users, :shipping_address, :string
    add_column :users, :shipping_address2, :string
    add_column :users, :shipping_city, :string
    add_column :users, :shipping_state_id, :integer
    add_column :users, :shipping_zipcode, :string
    add_column :users, :shipping_country_id, :integer
    add_column :users, :shipping_phone, :string
    add_column :users, :dorm_ship_college_name, :string
    add_column :users, :dorm_ship_not_assigned, :boolean
    add_column :users, :dorm_ship_not_part, :boolean
    add_column :users, :billing_phone, :string
    add_column :users, :whoami, :string
  end

  def self.down
    change_column_default :users, :user_profile_type_id, nil
    remove_column :users, :whoami
    remove_column :users, :billing_phone
    remove_column :users, :dorm_ship_not_part
    remove_column :users, :dorm_ship_not_assigned
    remove_column :users, :dorm_ship_college_name
    remove_column :users, :shipping_phone
    remove_column :users, :shipping_country_id
    remove_column :users, :shipping_zipcode
    remove_column :users, :shipping_state_id
    remove_column :users, :shipping_city
    remove_column :users, :shipping_address2
    remove_column :users, :shipping_address
    remove_column :users, :shipping_last_name
    remove_column :users, :shipping_first_name
    remove_column :users, :billing_country_id
    remove_column :users, :billing_zipcode
    remove_column :users, :billing_state_id
    remove_column :users, :billing_city
    remove_column :users, :billing_address2
    remove_column :users, :billing_address
    remove_column :users, :billing_last_name
    remove_column :users, :billing_first_name
    rename_column :users, :user_profile_type_id, :user_shipping_type_id
  end
end

