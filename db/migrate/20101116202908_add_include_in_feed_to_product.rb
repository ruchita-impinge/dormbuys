class AddIncludeInFeedToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :include_in_feeds, :boolean, :default => true
    execute "UPDATE products set include_in_feeds = 0 where drop_ship = 1;"
  end

  def self.down
    remove_column :products, :include_in_feeds
  end
end
