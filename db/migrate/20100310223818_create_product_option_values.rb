class CreateProductOptionValues < ActiveRecord::Migration
  def self.up
    create_table :product_option_values do |t|
      t.integer :product_option_id
      t.string :option_value
      t.decimal :weight_increase, :precision => 5, :scale => 3, :default => 0
      t.integer :display_order, :default => 0
      t.integer :int_price_increase, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :product_option_values
  end
end
