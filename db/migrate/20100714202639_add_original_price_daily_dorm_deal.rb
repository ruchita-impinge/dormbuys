class AddOriginalPriceDailyDormDeal < ActiveRecord::Migration
  def self.up
    add_column :daily_dorm_deals, :int_original_price, :integer, :default => 0
  end

  def self.down
    remove_column :daily_dorm_deals, :int_original_price
  end
end
