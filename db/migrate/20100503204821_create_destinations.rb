class CreateDestinations < ActiveRecord::Migration
  def self.up
    create_table :destinations do |t|
      t.string :postal_code
      t.string :state_province
      t.string :city

      t.timestamps
    end
  end

  def self.down
    drop_table :destinations
  end
end
