class JoinProductsVendors < ActiveRecord::Migration
  def self.up
    create_table :products_vendors, :id => false do |t|
      t.integer :product_id
      t.integer :vendor_id
    end
  end

  def self.down
    drop_table :products_vendors
  end
end
