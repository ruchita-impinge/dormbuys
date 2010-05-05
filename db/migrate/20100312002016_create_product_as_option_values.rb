class CreateProductAsOptionValues < ActiveRecord::Migration
  def self.up
    create_table :product_as_option_values do |t|
      t.integer :product_variation_id
      t.integer :product_as_option_id
      t.string :display_value
      t.integer :int_price_adjustment, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :product_as_option_values
  end
end
