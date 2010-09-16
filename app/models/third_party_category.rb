class ThirdPartyCategory < ActiveRecord::Base
  
  LNT = "Linens-N-Things"
  LNT2 = "Linens-N-Things ALL"
  SEARS = "Sears"
  
  ## NOTE: there is a 'data' attribute for any special 3rd party info, it is a varchar(255)
  
  validates_presence_of :name, :owner
  has_and_belongs_to_many :subcategories
  
  
  def self.grouped_options(third_party)
    options = []
    options << ["!! BLANK !!", [["!! BLANK !!", ""]]]
    
    ThirdPartyCategory.find_all_by_owner(third_party).group_by(&:parent).each do |parent, categories|
      
      options << [parent, categories.collect {|c| [c.name, c.id]}]
      
    end
    
    options
  end #end method grouped_options(third_party)
  
  
  def print_tree
    tree = [self.name]
    unless self.parent.blank?
      tree.unshift(self.parent) unless self.parent.blank?
      parent = ThirdPartyCategory.find(:first, :conditions => {:name => self.parent, :owner => self.owner, :level => self.level - 1})
      if parent
        tree.unshift(parent.parent) unless parent.parent.blank?
        parent2 = ThirdPartyCategory.find(:first, :conditions => {:name => parent.parent, :owner => parent.owner, :level => parent.level - 1})
        if parent2
          tree.unshift(parent2.parent) unless parent2.parent.blank?
        end
      end
    end
    tree.reject{|t| t if t.blank? }.join(" > ")
  end #end method print_tree

  
end #end class