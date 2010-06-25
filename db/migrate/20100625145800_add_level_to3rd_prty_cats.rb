class AddLevelTo3rdPrtyCats < ActiveRecord::Migration
  def self.up
    add_column :third_party_categories, :level, :integer, :default => 0
  end

  def self.down
    remove_column :third_party_categories, :level
  end
end
