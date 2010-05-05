class CreateOrderLineItemDiscounts < ActiveRecord::Migration
  def self.up
    create_table :order_line_item_discounts do |t|
      t.integer :order_line_item_id
      t.string :discount_message
      t.integer :int_discount_amount, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :order_line_item_discounts
  end
end
