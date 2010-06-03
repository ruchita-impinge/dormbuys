class JoinCartsGiftCards < ActiveRecord::Migration
  def self.up
    create_table :carts_gift_cards, :id => false do |t|
      t.integer :cart_id
      t.integer :gift_card_id
    end
  end

  def self.down
    drop_table :carts_gift_cards
  end
end
