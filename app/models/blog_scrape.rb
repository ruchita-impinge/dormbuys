class BlogScrape < ActiveRecord::Base
  
  validates_presence_of :title, :description, :link
  
  def self.latest
    BlogScrape.find(:first, :order => 'created_at DESC')
  end #end method self.latest
  
end
