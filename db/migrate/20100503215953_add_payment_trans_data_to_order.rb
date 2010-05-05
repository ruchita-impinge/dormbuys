class AddPaymentTransDataToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :payment_transaction_data, :text
  end

  def self.down
    remove_column :orders, :payment_transaction_data
  end
end
