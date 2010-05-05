class CreateCouriers < ActiveRecord::Migration
  def self.up
    create_table :couriers do |t|
      t.string :courier_name

      t.timestamps
    end
    
    Courier.create(:courier_name => "Fedex")
    Courier.create(:courier_name => "UPS")
    Courier.create(:courier_name => "DHL")
    Courier.create(:courier_name => "USPS")
    Courier.create(:courier_name => "Canada Post")

  end

  def self.down
    drop_table :couriers
  end
end
