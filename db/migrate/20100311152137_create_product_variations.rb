class CreateProductVariations < ActiveRecord::Migration
  def self.up
    create_table :product_variations do |t|
      t.integer :product_id
      t.string :title
      t.integer :qty_on_hand, :default => 0
      t.integer :qty_on_hold, :default => 0
      t.integer :reorder_qty, :default => 0
      t.integer :int_wholesale_price, :default => 0
      t.integer :int_freight_in_price, :default => 0
      t.integer :int_drop_ship_fee, :default => 0
      t.integer :int_shipping_in_price, :default => 0
      t.decimal :markup, :precision => 6, :scale => 3
      t.integer :int_list_price, :default => 0
      t.string :variation_group
      t.string :product_number
      t.string :manufacturer_number
      t.boolean :visible, :default => true
      t.string :wh_row, :limit => 5
      t.string :wh_bay, :limit => 5
      t.string :wh_shelf, :limit => 5
      t.string :wh_product, :limit => 5

      t.timestamps
    end
  end

  def self.down
    drop_table :product_variations
  end
end
