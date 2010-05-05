class CreateOrderLineItems < ActiveRecord::Migration
  def self.up
    create_table :order_line_items do |t|
      t.integer :order_id
      t.string :item_name
      t.integer :quantity
      t.string :vendor_company_name
      t.string :product_manufacturer_number
      t.string :product_number
      t.integer :int_unit_price, :default => 0
      t.integer :int_total, :default => 0
      t.boolean :product_drop_ship
      t.string :warehouse_location

      t.timestamps
    end
  end

  def self.down
    drop_table :order_line_items
  end
end
