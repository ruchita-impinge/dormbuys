class CreateWarehouses < ActiveRecord::Migration
  def self.up
    create_table :warehouses do |t|
      t.integer :vendor_id
      t.string :name
      t.string :address
      t.string :address2
      t.string :city
      t.integer :state_id
      t.string :zipcode
      t.integer :country_id

      t.timestamps
    end
  end

  def self.down
    drop_table :warehouses
  end
end
