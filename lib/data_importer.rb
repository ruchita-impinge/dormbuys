require "rexml/document"

class DataImporter
  
  def self.do_lnt_import
    f_path = "#{File.join(File.dirname(__FILE__), 'LNT-Current-Taxonomy.xml')}"
    doc = REXML::Document.new(File.new(f_path).read)
    data = []
    doc.elements.each("Table/Row/Cell/Data") {|e| data << e.text() }
    
    #loop through & create categories
    data.each do |d|
      splits = d.split(" / ")
      parent = splits.size == 1 ? "" : splits[splits.size-2]
      ThirdPartyCategory.create(:name => splits[splits.size-1], :parent => parent, :owner => "Linens-N-Things ALL", :level => splits.size)
    end #end each
    
  end #end method self.do_lnt_import
  
  
  
  def self.do_sears_import
    f_path = "#{File.join(File.dirname(__FILE__), 'SearsTagLibrary.xml')}"
    doc = REXML::Document.new(File.new(f_path).read)
    rows = []
    doc.elements.each("Table/Row") {|e| rows << e }
    
    rows.each do |row|
      cells = []
      row.elements.each("Cell/Data") {|e| cells << e.text() }
      
      #create individual variables
      tag         = cells[0]
      vertical    = cells[1]
      category    = cells[2]
      subcategory = cells[3]
      
      #create the vertical (this is for our own menu)
      v = ThirdPartyCategory.find(:first, :conditions => {:name => vertical, :parent => "", :owner => "Sears", :level => 1})
      ThirdPartyCategory.create(:name => vertical, :parent => "", :owner => "Sears", :level => 1) if v.blank?
      
      #create the category (this is for our own menu)
      c = ThirdPartyCategory.find(:first, :conditions => {:name => category, :parent => vertical, :owner => "Sears", :level => 2})
      ThirdPartyCategory.create(:name => category, :parent => vertical, :owner => "Sears", :level => 2) if c.blank?
      
      #create the subcategory, this is what really matters
      ThirdPartyCategory.create(:name => subcategory, :parent => category, :owner => "Sears", :level => 3, :data => tag)
      
    end #end each row


  end #end method self.do_sears_import
  
  
  
end #end class