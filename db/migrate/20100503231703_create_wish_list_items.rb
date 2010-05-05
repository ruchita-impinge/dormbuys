class CreateWishListItems < ActiveRecord::Migration
  def self.up
    create_table :wish_list_items do |t|
      t.integer :wish_list_id
      t.integer :product_variation_id
      t.integer :wish_qty
      t.integer :got_qty
      t.text :comments
      t.text :product_option_values
      t.text :product_as_option_values

      t.timestamps
    end
  end

  def self.down
    drop_table :wish_list_items
  end
end
