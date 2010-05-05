class CreateProductRestrictions < ActiveRecord::Migration
  def self.up
    create_table :product_restrictions do |t|
      t.integer :product_id
      t.integer :state_id
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :product_restrictions
  end
end
