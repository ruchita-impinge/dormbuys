class AddPackstreamToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :sent_to_packstream, :boolean, :default => false
    execute("UPDATE orders set sent_to_packstream = 1;")
  end

  def self.down
    remove_column :orders, :sent_to_packstream
  end
end
