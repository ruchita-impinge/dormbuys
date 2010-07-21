class CreateDailyDormDeals < ActiveRecord::Migration
  def self.up
    create_table :daily_dorm_deals do |t|
      t.datetime :start_time
      t.integer :type_id
      t.integer :product_id
      t.integer :product_variation_id
      t.string :title
      t.text :description
      t.integer :initial_qty

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_dorm_deals
  end
end
