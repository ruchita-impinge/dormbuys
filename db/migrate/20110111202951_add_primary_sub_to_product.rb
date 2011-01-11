class AddPrimarySubToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :primary_subcategory_id, :integer
  end

  def self.down
    remove_column :products, :primary_subcategory_id
  end
end