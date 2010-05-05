class UsersUpdate < ActiveRecord::Migration
  def self.up
    remove_column :users, :name
    remove_column :users, :login
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
  end

  def self.down
    add_column :users, :login, :string,                     :limit => 40
    remove_column :users, :phone
    remove_column :users, :last_name
    remove_column :users, :first_name
    add_column :users, :name, :string
  end
end
