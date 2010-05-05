class JoinSubcategoryThirdParthCategories < ActiveRecord::Migration
  def self.up
    create_table :subcategories_third_party_categories, :id => false do |t|
      t.integer :subcategory_id
      t.integer :third_party_category_id
    end
  end

  def self.down
    drop_table :subcategories_third_party_categories
  end
end
