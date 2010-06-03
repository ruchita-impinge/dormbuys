class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :address2
      t.string :city
      t.integer :state_id
      t.string :zip
      t.integer :country_id
      t.string :phone
      t.string :dorm_ship_college_name
      t.boolean :dorm_ship_not_assigned
      t.boolean :dorm_ship_not_part
      t.integer :address_type_id
      t.boolean :default_billing, :default => false
      t.boolean :default_shipping, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
