class CreateEmailListClients < ActiveRecord::Migration
  def self.up
    create_table :email_list_clients do |t|
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :email_list_clients
  end
end
