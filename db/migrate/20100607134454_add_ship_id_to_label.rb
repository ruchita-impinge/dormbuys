class AddShipIdToLabel < ActiveRecord::Migration
  def self.up
    add_column :shipping_labels, :identification_number, :string
  end

  def self.down
    remove_column :shipping_labels, :identification_number
  end
end
