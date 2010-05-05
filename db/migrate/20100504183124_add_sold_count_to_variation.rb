class AddSoldCountToVariation < ActiveRecord::Migration
  def self.up
    add_column :product_variations, :sold_count, :integer, :default => 0
  end

  def self.down
    remove_column :product_variations, :sold_count
  end
end
