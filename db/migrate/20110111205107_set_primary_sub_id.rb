class SetPrimarySubId < ActiveRecord::Migration
  def self.up
    products = Product.all
    products.each do |p|
      execute %(update products set primary_subcategory_id = (SELECT id FROM `subcategories` INNER JOIN `products_subcategories` ON `subcategories`.id = `products_subcategories`.subcategory_id WHERE (`products_subcategories`.product_id = #{p.id} ) LIMIT 1) where id = #{p.id};)
    end
  end

  def self.down
  end
end
