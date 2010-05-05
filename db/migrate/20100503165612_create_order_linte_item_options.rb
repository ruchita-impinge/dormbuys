class CreateOrderLinteItemOptions < ActiveRecord::Migration
  def self.up
    create_table :order_linte_item_options do |t|
      t.integer :order_line_item_id
      t.string :option_name
      t.string :option_value
      t.decimal :weight_increase, :precision => 6, :scale => 3, :default => 0
      t.integer :int_price_increase, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :order_linte_item_options
  end
end
