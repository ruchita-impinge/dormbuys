class ChangeCartDormShipDate < ActiveRecord::Migration
  def self.up
    rename_column :carts, :dorm_ship_date, :dorm_ship_ship_date
  end

  def self.down
    rename_column :carts, :dorm_ship_ship_date, :dorm_ship_date
  end
end
