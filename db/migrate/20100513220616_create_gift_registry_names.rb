class CreateGiftRegistryNames < ActiveRecord::Migration
  def self.up
    create_table :gift_registry_names do |t|
      t.integer :gift_registry_id
      t.string :first_name
      t.string :last_name
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :gift_registry_names
  end
end
