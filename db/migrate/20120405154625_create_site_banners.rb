class CreateSiteBanners < ActiveRecord::Migration
  def self.up
    create_table :site_banners do |t|
      t.string :title
      t.text :message
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :require_confirmation, :default => false
      t.boolean :allow_purchase, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :site_banners
  end
end
