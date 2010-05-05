class CreateShippingContainers < ActiveRecord::Migration
  def self.up
    create_table :shipping_containers do |t|
      t.string :title
      t.decimal :length, :precision => 5, :scale => 3
      t.decimal :width, :precision => 5, :scale => 3
      t.decimal :depth, :precision => 5, :scale => 3
      t.decimal :weight, :precision => 5, :scale => 3
      t.integer :qty_onhand
      t.boolean :demensional_weight, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_containers
  end
end
