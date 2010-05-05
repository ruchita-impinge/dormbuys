class CreateProductPackages < ActiveRecord::Migration
  def self.up
    create_table :product_packages do |t|
      t.decimal :weight, :precision => 6, :scale => 3
      t.decimal :length, :precision => 6, :scale => 3
      t.decimal :width, :precision => 6, :scale => 3
      t.decimal :depth, :precision => 6, :scale => 3
      t.boolean :ships_separately, :default => false
      t.integer :product_variation_id

      t.timestamps
    end
  end

  def self.down
    drop_table :product_packages
  end
end
