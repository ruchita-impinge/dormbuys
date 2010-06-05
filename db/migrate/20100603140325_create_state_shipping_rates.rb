class CreateStateShippingRates < ActiveRecord::Migration
  def self.up
    create_table :state_shipping_rates do |t|
      t.integer :state_id
      t.integer :int_additional_cost, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :state_shipping_rates
  end
end
