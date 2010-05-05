class CreateShippingNumbers < ActiveRecord::Migration
  def self.up
    create_table :shipping_numbers do |t|
      t.integer :order_line_item_id
      t.string :qty_description
      t.string :tracking_number
      t.integer :courier_id

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_numbers
  end
end
