class EnableShippingCountries < ActiveRecord::Migration
  def self.up
    add_column :countries, :ship_to_enabled, :boolean, :default => false
    Country.find_by_abbreviation("US").update_attribute :ship_to_enabled, true
  end

  def self.down
    remove_column :countries, :ship_to_enabled
  end
end
