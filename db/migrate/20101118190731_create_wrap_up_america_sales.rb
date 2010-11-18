class CreateWrapUpAmericaSales < ActiveRecord::Migration
  def self.up
    create_table :wrap_up_america_sales do |t|
      t.string :first_name
      t.string :last_name
      t.string :quantity
      t.string :campus
      t.string :team
      t.integer :cart_item_id
      t.boolean :purchase_confirmed, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :wrap_up_america_sales
  end
end
