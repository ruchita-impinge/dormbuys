class AddUserProfileTypeIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :user_shipping_type_id, :integer, :default => 0
  end

  def self.down
    remove_column :users, :user_shipping_type_id
  end
end
