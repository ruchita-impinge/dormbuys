# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
   
  def habtm_checkbox_list(classname, value_field, display_field, object_name, method_name, 
        checked_collection, cols=4, order_statement=nil)
    
    returning String.new do |html|
    
      unless order_statement
        order_statement = %(#{display_field} ASC)
      end
    
    
      counter = 1
      
      html << %(<table class="habtm_table">)
    
      @collection = Kernel.const_get(classname).find(:all, :order => order_statement)
      
      cols = @collection.size if @collection.size <= cols
    
      @collection.in_groups_of(cols, nil) do |row|
        
        html << %(<tr>)
        
        for obj in row
        
          unless obj.blank?
        
            html << %(<td><p class="habtm_checkbox">)
          
            html << check_box_tag("#{object_name}[#{method_name}][]", 
              obj.send(value_field), 
              checked_collection.include?(obj),
              :id => "#{object_name}_#{method_name}_#{obj.send(value_field)}")
          
            html << %(<label for="#{object_name}_#{method_name}_#{obj.send(value_field)}">#{obj.send(display_field)}</label>)
          
            html << %(</p></td>\n)
          
          else
            html << %(<td>&nbsp;</td>)
          end
        
        end
        
        html << %(</tr>)
             
      end #end loop over collection
      
      html << %(</table>)
    
    
    end #end returning
    
  end #end method habtm_checkbox_list(classname, value_field, display_field, object_name, method_name)
  
  
  
  # markaby helper method
  def markaby(&block)
    Markaby::Builder.new({}, self, &block)
  end #end method markaby(&block)
  
  
  
  def unique_text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {})
 
    id      = tag_options[:id] ? tag_options[:id] : "#{object}_#{method}_#{rand(1000000000000)}" 
    div_id  = "#{id}_auto_complete"
    name    = tag_options[:name] ? tag_options[:name] : "#{object}[#{method}]" 
    size    = tag_options[:size] ? tag_options[:size] : "30"
    value   = tag_options[:value] ? tag_options[:value] : ""
    style   = tag_options[:style] ? tag_options[:style] : ""
    klass   = tag_options[:class] ? tag_options[:class] : ""
    
    if completion_options[:url]
      url = completion_options[:url]
    else
      url = "#{url_for(:controller => controller.controller_name)}/auto_complete_for_#{object}_#{method}" 
    end
    
    url += "?object=#{object}&method=#{method}"
    
    if completion_options[:extra_params]
      url += "&#{completion_options[:extra_params]}"
    end
    
    
    all_options = {:id => id, :name => name, :size => size, :value => value, :style => style, :class => klass}
    use_options = {}
    all_options.each do |k,v|
      unless v.blank?
        use_options[k] = v
      end
    end
    
    output = %{<input type="text" }
    use_options.each do |k,v|
      output += %{#{k}="#{v}" }
    end
    output += " />\n"
    

    output += <<-EOJS
      <div class="auto_complete" id="#{div_id}"></div>
      <script type="text/javascript">
        //<![CDATA[
    				$('##{id}').autocomplete({update:'#{div_id}', url:'#{url}', 
    				afterUpdateElement:function(e){
              if(typeof afterAutoComplete == 'function')
              {
                  afterAutoComplete(e);
              }
    				},
    				beforeUpdateElement:function(e){
    				  if(typeof beforeAutoComplete == 'function')
    				  {
    				      beforeAutoComplete(e);
    				  }
    				}})
    		//]]>
      </script>
    EOJS
    
    output
    
  end #end unique_text...
  
  
  
  def select_product_options(po, name, selected, css_classes = [], use_select_word = true)
    out = %(<select name=#{name} class="#{css_classes.empty? ? 'inner-select2' : css_classes.join(" ")}" title="select">)
    out += %(<option value="">#{use_select_word ? 'Select ' : ''}#{po.option_name}...</option>)
    for value in po.product_option_values
      out += %(<option value="#{value.id}"#{' selected' if value.id == selected}>
        #{h value.option_value} #{value.price_increase.cents > 0 ? '(+ $' + value.price_increase.to_s + ')' : ''}
      </option>)
    end
    out += %(</select>)
    out
  end #end method select_product_options(object, method_name, selected)
  
  
  
  def select_product_as_options(pao, name, selected, css_classes = [])
    out = %(<select name=#{name} class="#{css_classes.empty? ? 'inner-select2' : css_classes.join(" ")}" title="select">)
    out += %(<option value="">Select "#{pao.option_name}"...</option>)
    for value in pao.product_as_option_values
      out += %(<option value="#{value.id}"#{' selected' if value.id == selected}>
        #{h value.display_value} #{
        if value.price_adjustment.cents > 0
          '(+ $' + (value.product_variation.rounded_retail_price + value.price_adjustment).to_s + ')'
        elsif value.price_adjustment.cents < 0
          '(+ $' + (value.product_variation.rounded_retail_price - value.price_adjustment).to_s + ')'
        else
          '(+ $' + value.product_variation.rounded_retail_price.to_s + ')'
        end
        }
      </option>)
    end
    out += %(</select>)
    out
  end #end method select_product_as_optoins(pao, name, selected)
  
  
  
  def select_product_variations(product, name, selected, for_admin=false)
    out = %(<select name="#{name}">)
    out += %(<option value="">Select #{product.available_variations.first.variation_group}...</option>) unless for_admin
    out += %(<option value="">Select #{product.product_variations.first.variation_group}...</option>) if for_admin
    for variation in product.product_variations
      out += %(<option value="#{variation.id}"#{' selected' if variation.id == selected}>
        #{variation.title}
      </option>)
    end
    out += %(</select>)
    out
  end #end method select_product_variations(product)
  
  
  
  #helper to get a pluralized name
  def pluralized_name(count, word)
    chunks = word.split(" ")
    if chunks.size > 1
      parts = word.gsub(/\?/, "").split(" ")
      parts[parts.length-1] = parts.last.pluralize
      parts.join(" ")
    else
      word.pluralize.gsub(" ", "")
    end
  end #end pluralized_name
  
  
  
  #creates options_for_select for product variations of a product.
  def product_variations_for_select(product)
    
    variations = []
    product.available_variations.each do |v| 
      
      var = {:title => v.title, :id => v.id}
      
      if v.rounded_retail_price > v.product.retail_price
        var[:increase] = (v.rounded_retail_price - v.product.retail_price).cents
      else
        var[:increase] = 0
      end
      
      variations << var
      
    end #end collect
    
    
   #sort by price, increasing
   variations.sort! { |x,y| [x[:increase], x[:title]] <=> [y[:increase], y[:title]] }
   
   #loop to setup title & inner array
   variations.collect do |v|
     title = v[:title]
     
     if v[:increase] > 0
       title += " (+ $#{Money.new(v[:increase])})"
     end
     
     [title, v[:id]]
     
   end #end collect

  end #end method product_variations_for_select
  
  
end #end module