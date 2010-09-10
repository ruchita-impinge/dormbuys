require "rexml/document"

class LntImporter
  
  def self.do_import
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
    
  end #end method self.do_import
  
end #end class