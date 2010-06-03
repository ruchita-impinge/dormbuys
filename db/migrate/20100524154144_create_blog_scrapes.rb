class CreateBlogScrapes < ActiveRecord::Migration
  def self.up
    create_table :blog_scrapes do |t|
      t.string :title
      t.text :description
      t.string :link

      t.timestamps
    end
  end

  def self.down
    drop_table :blog_scrapes
  end
end
