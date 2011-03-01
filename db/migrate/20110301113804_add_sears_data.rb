class AddSearsData < ActiveRecord::Migration
  def self.up
    add_column :products, :should_list_on_sears, :boolean, :default => false
    add_column :products, :posted_to_sears_at, :datetime
    execute %(UPDATE product_variations SET was_posted_to_sears = 0;)
    execute %(UPDATE third_party_categories SET attributes_popuplated_at = NULL;)
    execute %(TRUNCATE TABLE third_party_variations;)
    execute %(TRUNCATE TABLE third_party_variation_attributes;)
  end

  def self.down
    remove_column :products, :posted_to_sears_at
    remove_column :products, :should_list_on_sears
  end
end