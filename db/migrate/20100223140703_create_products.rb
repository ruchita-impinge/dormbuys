class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :product_name
      t.string :option_text
      t.text :product_overview
      t.text :product_details
      t.text :meta_keywords
      t.text :meta_description
      t.boolean :charge_tax, :default => true
      t.boolean :featured_item, :default => false
      t.boolean :visible, :default => true
      t.boolean :charge_shipping, :default => true
      t.boolean :drop_ship, :default => false
      t.boolean :exclude_from_coupons, :default => false
      t.boolean :allow_in_gift_registry, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
