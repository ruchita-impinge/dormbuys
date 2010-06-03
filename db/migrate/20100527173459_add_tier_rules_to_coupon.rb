class AddTierRulesToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :tier_rules, :string
  end

  def self.down
    remove_column :coupons, :tier_rules
  end
end
