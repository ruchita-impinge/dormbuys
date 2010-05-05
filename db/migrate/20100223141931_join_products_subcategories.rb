class JoinProductsSubcategories < ActiveRecord::Migration
  def self.up
    create_table :products_subcategories, :id => false do |t|
      t.integer :product_id
      t.integer :subcategory_id
    end
  end

  def self.down
    drop_table :products_subcategories
  end
end
