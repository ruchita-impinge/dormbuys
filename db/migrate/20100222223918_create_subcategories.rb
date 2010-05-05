class CreateSubcategories < ActiveRecord::Migration
  def self.up
    create_table :subcategories do |t|
      t.string :name
      t.text :description
      t.text :keywords
      t.integer :category_id
      t.integer :parent_id
      t.boolean :visible, :default => true
      t.integer :display_order, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :subcategories
  end
end
