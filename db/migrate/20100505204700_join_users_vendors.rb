class JoinUsersVendors < ActiveRecord::Migration
  def self.up
    create_table :users_vendors, :id => false do |t|
      t.integer :user_id
      t.integer :vendor_id
    end
  end

  def self.down
    drop_table :users_vendors
  end
end
