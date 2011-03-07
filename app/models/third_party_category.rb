class ThirdPartyCategory < ActiveRecord::Base
  
  LNT = "Linens-N-Things"
  LNT2 = "Linens-N-Things ALL"
  SEARS = "Sears"
  
  ## NOTE: there is a 'data' attribute for any special 3rd party info, it is a varchar(255)
  
  validates_presence_of :name, :owner
  has_and_belongs_to_many :subcategories
  has_many :third_party_variations
  
  
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
  
  
  def sears_populate_name_values
    ## before we start kill off any existing varition & attributes
    self.third_party_variations.each do |v|
      v.destroy
    end
    
    tag = self.data
    api = SearsAPI.new
    results = api.get_variation_name_attributes(tag)
    results.each do |data|
      puts "building variation: #{data[:name]}"
      variation = third_party_variations.build(:name => data[:name], :owner => ThirdPartyCategory::SEARS)
      variation.save(false)
      vid = variation.id
      data[:values].each do |val|
        puts "building attribute: #{val}"
        attribute = variation.third_party_variation_attributes.build(:value => val, :third_party_variation_id => vid)
        attribute.save(false)
      end
      ret = variation.save(false)
      puts "variation saved: #{ret}"
    end
    
    self.attributes_popuplated_at = Time.now
    self.save(false)
    
  end #end method sears_populate_name_values
  
  
  
  def self.populate_subcategory_sears_data
    temp_subs = Subcategory.all(:conditions => {:id => [49,89,88]})
    subcats = temp_subs #[120, temp_subs.length]
    begin
      subcats.each_with_index do |sub, i|
        puts "[populate sears] processing #{i} of #{subcats.length}"
        if sears_cat = sub.third_party_cat_obj(ThirdPartyCategory::SEARS)
          sears_cat.sears_populate_name_values if sears_cat.data
        end
        puts "[populate sears] done with #{i}"
      end
    rescue => e
      puts "\n\n\n[populate sears] CRASHED ON subcat ##{i}"
      raise "#{e.message}"
    end
  end #end method self.populate_subcategory_sears_data

  
end #end class