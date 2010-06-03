class CreateGiftRegistries < ActiveRecord::Migration
  def self.up
    create_table :gift_registries do |t|
      t.integer :user_id
      t.integer :registry_reason_id
      t.integer :registry_for_id
      t.string :title
      t.text :message
      t.date :event_date
      t.string :shipping_address
      t.string :shipping_address2
      t.string :shipping_city
      t.integer :shipping_state_id
      t.string :shipping_zip_code
      t.integer :shipping_country_id
      t.string :shipping_phone
      t.string :registry_number
      t.boolean :show_in_search_by_name, :default => true
      t.boolean :show_in_search_by_number, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :gift_registries
  end
end
