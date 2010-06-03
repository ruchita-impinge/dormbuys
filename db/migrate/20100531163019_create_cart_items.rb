class CreateCartItems < ActiveRecord::Migration
  def self.up
    create_table :cart_items do |t|
      t.integer :cart_id
      t.integer :product_variation_id
      t.integer :quantity
      t.string :product_option_values
      t.string :product_as_option_values
      t.integer :int_unit_price, :default => 0
      t.integer :int_total_price, :default => 0
      t.boolean :is_gift_registry_item, :default => false
      t.boolean :is_wish_list_item, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :cart_items
  end
end
