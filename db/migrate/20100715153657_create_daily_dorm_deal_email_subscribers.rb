class CreateDailyDormDealEmailSubscribers < ActiveRecord::Migration
  def self.up
    create_table :daily_dorm_deal_email_subscribers do |t|
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_dorm_deal_email_subscribers
  end
end
