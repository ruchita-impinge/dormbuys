class JoinProductsWarehouses < ActiveRecord::Migration
  def self.up
    create_table :products_warehouses, :id => false do |t|
      t.integer :product_id
      t.integer :warehouse_id
    end
  end

  def self.down
    drop_table :products_warehouses
  end
end
