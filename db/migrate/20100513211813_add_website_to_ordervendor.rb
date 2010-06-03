class AddWebsiteToOrdervendor < ActiveRecord::Migration
  def self.up
    add_column :order_vendors, :website, :string
  end

  def self.down
    remove_column :order_vendors, :website
  end
end
