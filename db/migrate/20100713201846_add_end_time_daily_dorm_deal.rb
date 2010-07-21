class AddEndTimeDailyDormDeal < ActiveRecord::Migration
  def self.up
    add_column :daily_dorm_deals, :end_time, :datetime
  end

  def self.down
    remove_column :daily_dorm_deals, :end_time
  end
end
