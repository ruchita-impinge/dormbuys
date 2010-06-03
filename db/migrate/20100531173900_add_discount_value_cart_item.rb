class AddDiscountValueCartItem < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :int_discount_value, :integer, :default => 0
  end

  def self.down
    remove_column :cart_items, :int_discount_value
  end
end
