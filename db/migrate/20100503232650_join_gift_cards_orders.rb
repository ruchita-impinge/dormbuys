class JoinGiftCardsOrders < ActiveRecord::Migration
  def self.up
    create_table :gift_cards_orders, :id => false do |t|
      t.integer :gift_card_id
      t.integer :order_id
    end
  end

  def self.down
    drop_table :gift_cards_orders
  end
end
