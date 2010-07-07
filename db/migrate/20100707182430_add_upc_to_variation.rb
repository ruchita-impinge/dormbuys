class AddUpcToVariation < ActiveRecord::Migration
  def self.up
    add_column :product_variations, :upc, :string
  end

  def self.down
    remove_column :product_variations, :upc
  end
end
