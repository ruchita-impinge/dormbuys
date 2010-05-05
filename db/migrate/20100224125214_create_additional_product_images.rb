class CreateAdditionalProductImages < ActiveRecord::Migration
  def self.up
    create_table :additional_product_images do |t|
      t.string :description
      t.integer :product_id
      t.timestamps
    end
  end

  def self.down
    drop_table :additional_product_images
  end
end
