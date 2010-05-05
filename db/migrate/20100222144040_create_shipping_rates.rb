class CreateShippingRates < ActiveRecord::Migration
  def self.up
    create_table :shipping_rates do |t|
      t.integer :int_subtotal, :default => 0
      t.integer :int_standard_rate, :default => 0
      t.integer :int_express_rate, :default => 0
      t.integer :int_overnight_rate, :default => 0
      t.integer :shipping_rates_table_id

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_rates
  end
end
