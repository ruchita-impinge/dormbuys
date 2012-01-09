class AddVendorEmail < ActiveRecord::Migration
  def self.up
    add_column :vendors, :contact_email, :string
  end

  def self.down
    remove_column :vendors, :contact_email
  end
end