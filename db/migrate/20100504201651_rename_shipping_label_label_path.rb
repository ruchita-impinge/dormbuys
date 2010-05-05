class RenameShippingLabelLabelPath < ActiveRecord::Migration
  def self.up
    rename_column :shipping_labels, :label_path, :label
  end

  def self.down
    rename_column :shipping_labels, :label, :label_path
  end
end
