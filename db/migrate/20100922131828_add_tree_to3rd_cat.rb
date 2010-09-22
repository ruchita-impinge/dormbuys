class AddTreeTo3rdCat < ActiveRecord::Migration
  def self.up
    add_column :third_party_categories, :tree, :string
    add_index :third_party_categories, :owner
    
    cats = ThirdPartyCategory.all
    cats.each do |c|
      c.tree = c.print_tree
      c.save(false)
    end
  end

  def self.down
    execute "UPDATE third_party_categories set tree = '';"
    remove_index :third_party_categories, :owner
    remove_column :third_party_categories, :tree
  end
end
