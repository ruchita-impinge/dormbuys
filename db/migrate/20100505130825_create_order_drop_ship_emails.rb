class CreateOrderDropShipEmails < ActiveRecord::Migration
  def self.up
    create_table :order_drop_ship_emails do |t|
      t.integer :order_id
      t.integer :vendor_id
      t.string :email
      t.string :vendor_company_name

      t.timestamps
    end
  end

  def self.down
    drop_table :order_drop_ship_emails
  end
end
