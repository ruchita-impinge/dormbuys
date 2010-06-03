class AddCouponTypes < ActiveRecord::Migration
  def self.up
    CouponType.create(:id => 4, :name => "Tiered Dollar Discount")
    CouponType.create(:id => 5, :name => "Tiered Percentage Discount")
  end

  def self.down
    CouponType.find(4).destroy
    CouponType.find(5).destroy
  end
end
