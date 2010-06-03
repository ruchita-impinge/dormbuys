class CreateRefunds < ActiveRecord::Migration
  def self.up
    create_table :refunds do |t|
      t.integer :order_id
      t.string :transaction_id
      t.integer :user_id
      t.string :response_data
      t.string :message
      t.boolean :success
      t.integer :int_amount

      t.timestamps
    end
  end

  def self.down
    drop_table :refunds
  end
end
