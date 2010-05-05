module ProductHelper
  
  def subcat_selector(selected)
    out  = %(<select id="product_subcategory_ids" name="product[subcategory_ids][]">)
    out += %(<option value="">Subcategory...</option>)
    
    #add the categories
    for cat in Category.all
      out += %(<optgroup label="#{cat.name}">)
      
      #add the primary subcategories
      for sub in cat.subcategories
        
        if sub.has_children?
          
          out += %(<optgroup label="&nbsp;&nbsp;#{sub.name}">)
            for tertiary in sub.all_children
              out += %(<option value="#{tertiary.id}#{' selected' if selected.id == sub.id}">&nbsp;&nbsp;#{tertiary.name}</option>)
            end
          out += %(</optgroup>)
          
        elsif !sub.is_tertiary?
          
          out += %(<option value="#{sub.id}"#{' selected' if selected.id == sub.id}>#{sub.name}</option>)
          
        end #end if tertiary
      
      end #end primary sub-cat loop
      
      out += %(</optgroup>)
    end #end cat loop
    
    out += %(</select>)
    out
  end #end method subcat_selector(selected)
  
end
