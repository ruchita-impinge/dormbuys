class AddMultiDescProduct < ActiveRecord::Migration
  def self.up
    remove_column :products, :product_details 
    add_column :products, :description_general, :text
  end

  def self.down
    remove_column :products, :description_general
    add_column :products, :product_details, :text
  end
end
