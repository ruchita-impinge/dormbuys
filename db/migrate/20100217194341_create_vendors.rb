class CreateVendors < ActiveRecord::Migration
  def self.up
    create_table :vendors do |t|
      t.string :account_number
      t.string :company_name
      t.string :address
      t.string :address2
      t.string :city
      t.integer :state_id
      t.string :zipcode
      t.integer :country_id
      t.string :phone
      t.boolean :dropship
      t.boolean :enabled
      t.string :corporate_name
      t.string :fax
      t.string :website
      t.string :billing_address
      t.string :billing_address2
      t.string :billing_city
      t.integer :billing_state_id
      t.string :billing_zipcode
      t.integer :billing_country_id

      t.timestamps
    end
  end

  def self.down
    drop_table :vendors
  end
end
