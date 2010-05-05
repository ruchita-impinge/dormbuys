class CreateGiftCards < ActiveRecord::Migration
  def self.up
    create_table :gift_cards do |t|
      t.string :giftcard_number
      t.string :giftcard_pin
      t.integer :int_current_amount, :default => 0
      t.integer :int_original_amount, :default => 0
      t.boolean :expires
      t.date :expiration_date

      t.timestamps
    end
  end

  def self.down
    drop_table :gift_cards
  end
end
