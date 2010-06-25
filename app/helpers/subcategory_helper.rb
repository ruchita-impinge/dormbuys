module SubcategoryHelper
  
  
  def third_party_select_options(third_party, selected_id)
    #return  @options unless  @options.blank?
    
    
    @options = []
    @options << %(<option value="">!! BLANK !!</option>)
    

    cats = ThirdPartyCategory.find_all_by_owner(third_party)
    
    level_one_cats = cats.reject {|c| c unless c.level == 1 }
    
    get_children = Proc.new do |parent_cat|
      cats.reject {|c| c unless c.parent == parent_cat.name && c.level > parent_cat.level }
    end
    
    

    
    for top_cat in level_one_cats
      
      counter = 0
      spacer = '&nbsp;&nbsp;'
      
      level_two_cats = get_children.call(top_cat)
      
      if level_two_cats.empty?
        counter = 0
        @options << %(<option value="#{top_cat.id}"#{' selected="selected"' if top_cat.id == selected_id}>#{spacer*counter}#{top_cat.name}</option>)
      else
        @options << %(<option value="#{top_cat.id}" disabled="disabled">#{spacer*counter}#{top_cat.name}</option>)
        counter = 1
        
        for second_cat in level_two_cats
          level_three_cats = get_children.call(second_cat)
          if level_three_cats.empty?
            counter = 1
            @options << %(<option value="#{second_cat.id}"#{' selected="selected"' if second_cat.id == selected_id}>#{spacer*counter}#{second_cat.name}</option>)
          else
            @options << %(<option value="#{second_cat.id}" disabled="disabled">#{spacer*counter}#{second_cat.name}</option>)
            counter = 2
            
            for third_cat in level_three_cats
              level_four_cats = get_children.call(third_cat)
              if level_four_cats.empty?
                counter = 2
                @options << %(<option value="#{third_cat.id}"#{' selected="selected"' if third_cat.id == selected_id}>#{spacer*counter}#{third_cat.name}</option>)
              else
                @options << %(<option value="#{third_cat.id}" disabled="disabled">#{spacer*counter}#{third_cat.name}</option>)
                counter = 3
                
                for fourth_cat in level_four_cats
                  level_five_cats = get_children.call(fourth_cat)
                  if level_five_cats.empty?
                    counter = 3
                    @options << %(<option value="#{fourth_cat.id}"#{' selected="selected"' if fourth_cat.id == selected_id}>#{spacer*counter}#{fourth_cat.name}</option>)
                  else
                    @options << %(<option value="#{fourth_cat.id}" disabled="disabled">#{spacer*counter}#{fourth_cat.name}</option>)
                    counter = 4
                    
                    for fifth_cat in level_five_cats
                      level_six_cats = get_children.call(fifth_cat)
                      if level_six_cats.empty?
                        @options << %(<option value="#{fifth_cat.id}"#{' selected="selected"' if fifth_cat.id == selected_id}>#{spacer*counter}#{fifth_cat.name}</option>)
                      else
                        @options << %(<option value="">!! UNSUPPORTED CAT DEPTH !!</option>)
                      end
                    end #end loop over level_five_cats
                    
                  end #end if level_five_cats.empty?
                  
                end #end loop over level_four_cats
                
              end #end if level_four_cats.empty?
              
            end #end loop over level_three_cats
            
          end #end level_three_cats.empty?
          
        end #end loop over level_two_cats
        
      end #end level_two_cats.empty?
      
      
    end #end loop over top level cats
    
    
    return @options
  end #end method third_party_select_@options
  
  
end #end module