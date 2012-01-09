class AddFieldsToVendors < ActiveRecord::Migration
  
  def self.up
    add_column :vendors, :contact_name, :string
    add_column :vendors, :notes, :text
  end

  def self.down
    remove_column :vendors, :notes
    remove_column :vendors, :contact_name
  end
end