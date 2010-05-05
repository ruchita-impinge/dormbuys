class RenameOrderLineItemOptionsTable < ActiveRecord::Migration
  def self.up
    rename_table :order_linte_item_options, :order_line_item_options
  end

  def self.down
    rename_table :order_line_item_options, :order_linte_item_options
  end
end
