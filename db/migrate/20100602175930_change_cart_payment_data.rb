class ChangeCartPaymentData < ActiveRecord::Migration
  def self.up
    change_column :carts, :payment_data, :binary
  end

  def self.down
    change_column :carts, :payment_data, :text
  end
end
