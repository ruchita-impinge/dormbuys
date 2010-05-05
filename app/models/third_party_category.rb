class ThirdPartyCategory < ActiveRecord::Base
  
  LNT = "Linens-N-Things"
  
  validates_presence_of :name, :owner
  has_and_belongs_to_many :subcategories
  
  
  def self.grouped_options(third_party)
    options = []
    
    ThirdPartyCategory.find_all_by_owner(third_party).group_by(&:parent).each do |parent, categories|
      
      options << [parent, categories.collect {|c| [c.name, c.id]}]
      
    end
    
    options
  end #end method grouped_options(third_party)
  
end #end class
