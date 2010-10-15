class CreateThirdPartyVariationAttributes < ActiveRecord::Migration
  def self.up
    create_table :third_party_variation_attributes do |t|
      t.integer :third_party_variation_id
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :third_party_variation_attributes
  end
end
