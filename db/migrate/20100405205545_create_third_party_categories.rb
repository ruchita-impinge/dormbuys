class CreateThirdPartyCategories < ActiveRecord::Migration
  def self.up
    create_table :third_party_categories do |t|
      t.string :name
      t.string :owner
      t.string :parent

      t.timestamps
    end
  end

  def self.down
    drop_table :third_party_categories
  end
end
