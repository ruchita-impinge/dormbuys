class CreateThirdPartyVariations < ActiveRecord::Migration
  def self.up
    create_table :third_party_variations do |t|
      t.string :owner
      t.integer :third_party_category_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :third_party_variations
  end
end
