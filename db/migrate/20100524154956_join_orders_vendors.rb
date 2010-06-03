class JoinOrdersVendors < ActiveRecord::Migration
  def self.up
    create_table :orders_vendors, :id => false do |t|
      t.integer :order_id
      t.integer :vendor_id
    end
  end

  def self.down
    drop_table :orders_vendors
  end
end
