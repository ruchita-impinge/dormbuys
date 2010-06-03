class CreateWishLists < ActiveRecord::Migration
  def self.up
    create_table :wish_lists do |t|
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :wish_lists
  end
end
