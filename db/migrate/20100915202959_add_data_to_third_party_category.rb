class AddDataToThirdPartyCategory < ActiveRecord::Migration
  def self.up
    add_column :third_party_categories, :data, :string
  end

  def self.down
    remove_column :third_party_categories, :data
  end
end
