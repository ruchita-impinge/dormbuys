class CreateShippingLabels < ActiveRecord::Migration
  def self.up
    create_table :shipping_labels do |t|
      t.integer :order_id
      t.string :label_path
      t.string :tracking_number

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_labels
  end
end
