class CreateOrderVendors < ActiveRecord::Migration
  def self.up
    create_table :order_vendors do |t|
      t.string :name
      t.string :address
      t.string :address2
      t.string :city
      t.integer :state_id
      t.string :zip_code
      t.integer :country_id
      t.string :customer_service_phone
      t.string :customer_service_email

      t.timestamps
    end
    add_column :orders, :order_vendor_id, :integer
  end

  def self.down
    remove_column :orders, :order_vendor_id
    drop_table :order_vendors
  end
end
