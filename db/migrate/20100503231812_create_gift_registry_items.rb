class CreateGiftRegistryItems < ActiveRecord::Migration
  def self.up
    create_table :gift_registry_items do |t|
      t.integer :gift_registry_id
      t.integer :product_variation_id
      t.integer :desired_qty
      t.integer :received_qty
      t.text :comments
      t.string :product_option_values
      t.string :product_as_option_values

      t.timestamps
    end
  end

  def self.down
    drop_table :gift_registry_items
  end
end
