class CreateGiftCardReports < ActiveRecord::Migration
  def self.up
    create_table :gift_card_reports do |t|
      t.text :csv_data
      t.integer :valid_count
      t.integer :valid_total
      t.integer :all_count
      t.integer :all_total

      t.timestamps
    end
  end

  def self.down
    drop_table :gift_card_reports
  end
end
