class CreateQuantityDiscounts < ActiveRecord::Migration
  def self.up
    create_table :quantity_discounts do |t|
      t.integer :discount_type, :default => 0
      t.integer :each_next, :default => 0
      t.integer :buy_qty, :default => 1
      t.integer :next_qty, :default => 1
      t.string :message
      t.integer :int_value, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :quantity_discounts
  end
end
