class AddSaltToCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :salt, :string
  end

  def self.down
    remove_column :carts, :salt
  end
end
