class AddSearsAttributesToVariations < ActiveRecord::Migration
  def self.up
    add_column :product_variations, :sears_variation_name, :string
    add_column :product_variations, :sears_variation_attribute, :string
  end

  def self.down
    remove_column :product_variations, :sears_variation_attribute
    remove_column :product_variations, :sears_variation_name
  end
end
