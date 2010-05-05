class CreateOrderLineItemProductAsOptions < ActiveRecord::Migration
  def self.up
    create_table :order_line_item_product_as_options do |t|
      t.integer :order_line_item_id
      t.string :option_name
      t.string :display_value
      t.integer :int_price, :default => 0
      t.string :product_name
      t.string :product_number

      t.timestamps
    end
  end

  def self.down
    drop_table :order_line_item_product_as_options
  end
end
