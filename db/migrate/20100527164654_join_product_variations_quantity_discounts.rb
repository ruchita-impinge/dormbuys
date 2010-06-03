class JoinProductVariationsQuantityDiscounts < ActiveRecord::Migration
  def self.up
    create_table :product_variations_quantity_discounts, :id => false do |t|
      t.integer :product_variation_id
      t.integer :quantity_discount_id
    end
  end

  def self.down
    drop_table :product_variations_quantity_discounts
  end
end
