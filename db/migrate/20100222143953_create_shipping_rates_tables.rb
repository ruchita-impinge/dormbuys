class CreateShippingRatesTables < ActiveRecord::Migration
  def self.up
    create_table :shipping_rates_tables do |t|
      t.boolean :enabled

      t.timestamps
    end
    ShippingRatesTable.create(:enabled => true)
  end

  def self.down
    drop_table :shipping_rates_tables
  end
end
