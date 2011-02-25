class VariationsPostedToSears < ActiveRecord::Migration
  def self.up
    add_column :product_variations, :was_posted_to_sears, :boolean, :default => false
  end

  def self.down
    remove_column :product_variations, :was_posted_to_sears
  end
end