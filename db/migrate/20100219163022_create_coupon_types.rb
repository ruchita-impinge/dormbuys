class CreateCouponTypes < ActiveRecord::Migration
  def self.up
    create_table :coupon_types do |t|
      t.string :name

      t.timestamps
    end
    CouponType.create(:name => "Fixed Dollar Discount")
    CouponType.create(:name => "Total Percentage Discount")
    CouponType.create(:name => "Free Shipping")
  end

  def self.down
    drop_table :coupon_types
  end
end
