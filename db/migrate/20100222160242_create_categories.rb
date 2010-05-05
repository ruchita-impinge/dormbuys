class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.text :keywords
      t.boolean :visible, :default => true
      t.integer :display_order, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
