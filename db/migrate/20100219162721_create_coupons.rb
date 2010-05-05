class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.string :coupon_number
      t.boolean :expires, :default => true
      t.date :expiration_date
      t.boolean :reusable, :default => true
      t.boolean :used, :default => false
      t.string :description
      t.integer :int_min_purchase, :default => 0
      t.integer :int_value, :default => 0
      t.integer :coupon_type_id
      t.boolean :is_free_shipping, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end
