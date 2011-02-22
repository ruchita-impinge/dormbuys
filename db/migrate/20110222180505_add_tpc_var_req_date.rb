class AddTpcVarReqDate < ActiveRecord::Migration
  def self.up
    add_column :third_party_categories, :attributes_popuplated_at, :datetime
    ThirdPartyCategory.seed_attributes_popuplated_at
  end

  def self.down
    remove_column :third_party_categories, :attributes_popuplated_at
  end
end