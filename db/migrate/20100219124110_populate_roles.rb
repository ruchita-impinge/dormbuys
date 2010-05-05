class PopulateRoles < ActiveRecord::Migration
  def self.up
    Role.create(:name => "customer")
    Role.create(:name => "admin")
  end

  def self.down
    Role.delete_all
  end
end
