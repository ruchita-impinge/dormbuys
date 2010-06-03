class AddPermalinkHandles < ActiveRecord::Migration
  def self.up
    add_column :categories, :permalink_handle, :string
    add_column :subcategories, :permalink_handle, :string
    add_column :products, :permalink_handle, :string
    
    add_index :categories, :permalink_handle
    add_index :subcategories, :permalink_handle
    add_index :products, :permalink_handle
  end

  def self.down
    remove_index :products, :permalink_handle
    remove_index :subcategories, :permalink_handle
    remove_index :categories, :permalink_handle
    
    remove_column :products, :permalink_handle
    remove_column :subcategories, :permalink_handle
    remove_column :categories, :permalink_handle
  end
end
