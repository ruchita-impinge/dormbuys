module ProductHelper
  
  def subcat_selector(selected, element_name="")
    out  = %(<select id="product_subcategory_ids" name="#{element_name.blank? ? 'product[subcategory_ids][]' : element_name}">)
    out += %(<option value="">Subcategory...</option>)
    
    #add the categories
    for cat in Category.all
      out += %(<optgroup label="#{cat.name}">)
      
      #add the primary subcategories
      for sub in cat.subcategories
        
        if sub.has_children?
          
          out += %(<option value="" disabled="disabled">&nbsp;&nbsp;#{sub.name}</option>)
          
          for tertiary in sub.all_children
            out += %(<option value="#{tertiary.id}" #{'selected="selected"' if selected.id == tertiary.id}>&nbsp;&nbsp;&nbsp;&nbsp;#{tertiary.name}</option>)
          end
        
        elsif !sub.is_tertiary?
          
          out += %(<option value="#{sub.id}" #{' selected="selected"' if selected.id == sub.id}>#{sub.name}</option>)
          
        end #end if tertiary
      
      end #end primary sub-cat loop
      
      out += %(</optgroup>)
    end #end cat loop
    
    out += %(</select>)
    out
  end #end method subcat_selector(selected)
  
  
  
  
  def brand_selector(selected)
    out  = %(<select id="product_brand_ids" name="product[brand_ids][]">)
    out += %(<option value="">Brand...</option>)
    
    for brand in Brand.all
      out += %(<option value="#{brand.id}"#{' selected' if selected.id == brand.id}>#{brand.name}</option>)
    end #end loop
    
    out += %(</select>)
    out
  end #end method brand_selector
  
  
  
end
