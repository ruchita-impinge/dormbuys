class JoinBrandsNOthers < ActiveRecord::Migration
  def self.up
    
    create_table :brands_products, :id => false do |t|
      t.integer :brand_id
      t.integer :product_id
    end
    
    create_table :brands_vendors, :id => false do |t|
      t.integer :brand_id
      t.integer :vendor_id
    end
    
    add_index :brands_products, :brand_id
    add_index :brands_products, :product_id
    add_index :brands_vendors, :brand_id
    add_index :brands_vendors, :vendor_id
    
  end

  def self.down
    remove_index :brands_vendors, :vendor_id
    remove_index :brands_vendors, :brand_id
    remove_index :brands_products, :product_id
    remove_index :brands_products, :brand_id
    
    drop_table :brands_products
    drop_table :brands_vendors
  end
end
