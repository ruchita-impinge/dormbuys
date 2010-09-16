class CreateSearsTransmissions < ActiveRecord::Migration
  def self.up
    create_table :sears_transmissions do |t|
      t.datetime :sent_at
      t.text :variations
      t.text :description
      t.boolean :sync_inventory

      t.timestamps
    end
  end

  def self.down
    drop_table :sears_transmissions
  end
end
