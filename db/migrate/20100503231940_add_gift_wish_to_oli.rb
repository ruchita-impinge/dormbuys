class AddGiftWishToOli < ActiveRecord::Migration
  def self.up
    add_column :order_line_items, :wish_list_item_id, :integer
    add_column :order_line_items, :gift_registry_item_id, :integer
  end

  def self.down
    remove_column :order_line_items, :gift_registry_item_id
    remove_column :order_line_items, :wish_list_item_id
  end
end
