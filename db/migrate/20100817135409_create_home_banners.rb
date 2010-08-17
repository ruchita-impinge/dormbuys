class CreateHomeBanners < ActiveRecord::Migration
  def self.up
    create_table :home_banners do |t|
      t.boolean :is_main

      t.timestamps
    end
  end

  def self.down
    drop_table :home_banners
  end
end
