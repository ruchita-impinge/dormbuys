class Admin::ProductsController < Admin::AdminController
  
  before_filter :scrub_multi_model_params, :only => [:create, :update]
  
  
  
  
  ##[ Helper actions i.e Ajax etc. ]#########################################################
  ###########################################################################################
  ###########################################################################################
  ###########################################################################################
  
  
  def sears_variation_attributes

    variation_name = ThirdPartyVariation.find(:first, :conditions => {:name => params[:sears_variation_name], :owner => ThirdPartyCategory::SEARS})
    variation_id = params[:varaition_id]
    
    render :update do |page|
      if variation_name
        js_options = "var js_options#{variation_id} = [];\n"
        options = []
        
        if [4,6,9,10,13,15,16,18,19,21,22,23,25,27,29,31,33].include?(variation_name.id)
          
          sql = %(SELECT * FROM third_party_variation_attributes WHERE third_party_variation_id = #{variation_name.id} AND
          (value LIKE "Red:Red" OR
          value LIKE "Yellow:Yellow" OR
          value LIKE "Blue:Blue" OR
          value LIKE "Green:Green" OR
          value LIKE "Orange:Orange" OR
          value LIKE "Purple:Purple" OR
          value LIKE "Black:Black" OR
          value LIKE "Brown:Brown" OR
          value LIKE "Clear:Clear" OR
          value LIKE "Beige:Beige" OR
          value LIKE "Grey:Gray" OR
          value LIKE "White:White" OR
          value LIKE "Multi-color:Multi-color" OR
          value LIKE "Pink:Pink");)
          
          _attributes = ThirdPartyVariationAttribute.find_by_sql(sql)
          _attributes.each {|x| options << x.value }
          
        else
          variation_name.third_party_variation_attributes.collect {|x| options << x.value }
        end
        
        options.each_with_index do |opt, i|
          js_options += %(js_options#{variation_id}[#{i}] = "#{opt}";\n)
        end
        page << js_options
        
        js_code = <<-eojs
          var options_html = "";
          js_options#{variation_id}.map(function(opt){
            options_html += '<option id="' + addslashes(opt) + '">' + addslashes(opt) + '</option>';
          });
          $("#sears_variation_attribute_#{variation_id} select").html(options_html);
        eojs
        
        page << js_code
        
        #page << %( $("#sears_variation_attribute_#{variation_id} select").html("#{options_html}"); )
      else
        page.alert("Couldn't find third party variation with name: #{params[:sears_variation_name]}")
      end
    end
    
  end #end method sears_variation_attributes
  
  
  
  

  def auto_complete_for_product_product_name

    product_name = params[:product].values.first[:pao_value_attributes].first[:product_variation_name]

    @products = Product.find(:all, 
      :conditions => [ "LOWER(#{params[:method]}) LIKE ?",
      '%' + product_name.downcase + '%'], 
      :order => "#{params[:method]} ASC",
      :limit => 10)
    @variations = @products.collect {|p| p.product_variations }.flatten

    render :partial => 'auto_complete_list', :object => @variations
  end
  

  #link_to_remote methods
  #method to add dynamic methods to our model
   def make_dynamic(p)

     #dynamically create setters for product_as_option_attributes
     0.upto(100) do |i|
       p.class.send(:define_method, "product_as_option_attributes_#{i}=", 
       proc do |args|
         if args[:id].blank?
           p.product_as_options.build(args)
         else
           pao = p.product_as_options.detect {|x| x.id == args[:id].to_i }
           pao.attributes = args
         end
       end)
     end

     return p

   end #end method make_dynamic(p)
   
   
   
  def add_option
    
    nc =  params[:count].to_i + 1 #nc is NUMBER of options COUNT

    render :update do |page|
      page << "$(\"#options_count\").val(\"#{nc}\")"
      page.insert_html :bottom, "product_options", 
			  :partial => "product_option.html.erb", 
			  :object => ProductOption.new,
			  :locals => {:i => nc}
		end
  end #end method add_option
  
  
  
  def add_option_value
    render :update do |page|
      page.insert_html :bottom, "option_values_#{params[:id]}",
        :partial => 'product_option_value',
        :object => ProductOptionValue.new,
        :locals => {:j => params[:id]}
    end
  end #end method add_option_value
  
  
  
  def add_pao
    nc =  params[:count].to_i + 1 #nc is NUMBER of options COUNT

    render :update do |page|
      page << "$(\"#pao_count\").val(\"#{nc}\");"
      page.insert_html :bottom, "product_as_options", 
			  :partial => "product_as_option.html.erb", 
			  :object => ProductAsOption.new,
			  :locals => {:i => nc}
		end
  end #end method add_pao
  
  
  def add_pao_value
    render :update do |page|
      page.insert_html :bottom, "pao_values_#{params[:id]}", 
        :partial => 'product_as_option_value', 
        :object => ProductAsOptionValue.new, 
        :locals => {:j => params[:id]}
    end
  end #end method add_pao_value
  
  
  
  
  def add_variation
    render :update do |page|
      pv = ProductVariation.new_default
      params[:pp_count].to_i.times { pv.product_packages.build }
      page.insert_html :bottom, "product_variations", :partial => "product_variation", :object => pv
      js_copy = <<-eo_js
      
      var vSize = $(".variation").length;
      
      if(vSize >= 2)
      {
      
        var last = $(".variation").eq($(".variation").length-1);
        var prev = $(".variation").eq($(".variation").length-2);
        
        last.contents().find('.title').val(prev.contents().find('.title').val());
        last.contents().find('.qty_on_hand').val(prev.contents().find('.qty_on_hand').val());
        last.contents().find('.qty_on_hold').val(prev.contents().find('.qty_on_hold').val());
        last.contents().find('.reorder_qty').val(prev.contents().find('.reorder_qty').val());
        last.contents().find('.variation_group').val(prev.contents().find('.variation_group').val());
        
        var vis = last.contents().find('.visible');
        
        if(vis.is(":checked")){
          prev.contents().find('.visible').attr("checked", "true");
        }else{
          prev.contents().find('.visible').attr("checked", "false");
        }
        
        last.contents().find('.manufacturer_number').val(prev.contents().find('.manufacturer_number').val());
        last.contents().find('.upc').val(prev.contents().find('.upc').val());
        last.contents().find('.wholesale_price').val(prev.contents().find('.wholesale_price').val());
        last.contents().find('.freight_in_price').val(prev.contents().find('.freight_in_price').val());
        last.contents().find('.drop_ship_fee').val(prev.contents().find('.drop_ship_fee').val());
        last.contents().find('.shipping_in_price').val(prev.contents().find('.shipping_in_price').val());
        last.contents().find('.markup').val(prev.contents().find('.markup').val());
        last.contents().find('.list_price').val(prev.contents().find('.list_price').val());
        last.contents().find('.wh_row').val(prev.contents().find('.wh_row').val());
        last.contents().find('.wh_bay').val(prev.contents().find('.wh_bay').val());
        last.contents().find('.wh_shelf').val(prev.contents().find('.wh_shelf').val());
        last.contents().find('.wh_product').val(prev.contents().find('.wh_product').val());
        
        
        var package_count = prev.contents().find('.product_package').length;
        if( package_count == 1 )
        {
          var prev_pp = prev.contents().find('.product_package').eq(0);
          var last_pp = last.contents().find('.product_package').eq(0);
          last_pp.contents().find(".weight").val( prev_pp.contents().find(".weight").val() );
          last_pp.contents().find(".length").val( prev_pp.contents().find(".length").val() );
          last_pp.contents().find(".width").val( prev_pp.contents().find(".width").val() );
          last_pp.contents().find(".depth").val( prev_pp.contents().find(".depth").val() );
        }
        else if( package_count > 1)
        {

          /*
          var single_pp = last.contents().find(".product_package").eq(0).parent().html(); //we know it is single b/c it was just made
          last.contents().find(".v_product_packages").html("");
          for(var j=0; j < package_count; j++)
          {
              last.contents.find(".v_product_packages").append(single_pp);
          }
          */
          
          var prev_packages = prev.contents().find(".product_package");
          var last_packages = last.contents().find(".product_package");
          
          for(var i=0; i < prev_packages.length; i++)
          {
            
            last_packages.eq(i).contents().find(".weight").val( prev_packages.eq(i).contents().find(".weight").val() );
            last_packages.eq(i).contents().find(".length").val( prev_packages.eq(i).contents().find(".length").val() );
            last_packages.eq(i).contents().find(".width").val( prev_packages.eq(i).contents().find(".width").val() );
            last_packages.eq(i).contents().find(".depth").val( prev_packages.eq(i).contents().find(".depth").val() );
            last_packages.eq(i).contents().find(".hdn_ships_separately").val( prev_packages.eq(i).contents().find(".hdn_ships_separately").val() );
            last_packages.eq(i).contents().find(".ships_separately_check").attr("checked",  prev_packages.eq(i).contents().find(".ships_separately_check").is(":checked") );
          }//end for
          
        }//end else if
        
      }
      eo_js
    
      page << js_copy
      page << "setup_price_calcs();"
      page << "setupFileFields();"
    end
  end #end method add_variation
  
  
  def add_v_package
    render :update do |page|
      page.insert_html :bottom, "v_product_packages_#{params[:index]}", 
        :partial => 'product_package', 
        :object => ProductPackage.new, 
        :locals => {:index => params[:index]}
    end
  end #end method add_v_package
  
  
  def scrub_multi_model_params
    return unless params[:product] && params[:product][:product_variation_attributes]
    return unless params[:product_packages] && params[:product_packages][:product_variation_package_attributes]
    
    params[:product][:product_variation_attributes].each do |key, values|
      values.first[:product_package_attributes] = params[:product_packages][:product_variation_package_attributes][key]
    end
  end #end method scrub_multi_model_params
  
  
  
  ##[ Accessory Actions ]####################################################################
  ###########################################################################################
  ###########################################################################################
  ###########################################################################################
  
  
  
  def images
    @product = Product.find(params[:id])
  end #end method images
  
  
  def options
    @product = Product.find(params[:id])
  end #end method options
  
  
  def variations
    @product = Product.find(params[:id])
    
    if @product.product_variations.empty?
      v = @product.product_variations.build
      v.product_number = ProductVariation.create_product_number
      v.title = "default"
      pack = v.product_packages.build
    end
    
  end #end method variations
  
  
  def restricted
    @product = Product.find(params[:id])
  end #end method restricted
  
  
  def search
    @products = Product.find(:all, 
      :conditions => ["product_name LIKE ?", "%#{params[:search][:search_term]}%"]
      ).paginate :per_page => 50, :page => params[:page]
    
    render :action => :index
  end #end method search
  
  
  
  
  ##[ Standard CRUD ]########################################################################
  ###########################################################################################
  ###########################################################################################
  ###########################################################################################
  
  
  
  
  # GET /products
  # GET /products.xml
  def index
    @products = Product.find(:all, :order => 'product_name asc').paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new
    @product.warehouse_ids  = [3631]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    
    if params[:product][:subcategory_ids]
      params[:product][:subcategory_ids].uniq!
    end
    
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        flash[:notice] = 'Product was successfully created.'
        format.html { redirect_to(edit_admin_product_path(@product)) }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
        
    #kill any non-unique product sub-categories
    if params && params[:product] && params[:product][:subcategory_ids]
      params[:product][:subcategory_ids].uniq!
    end
    
    @product = Product.find(params[:id])
        
    #setup the end action for redirects & renders
    if params[:end_action]
      go_to = {:action => params[:end_action].to_sym, :id => @product }
    else
      go_to = edit_admin_product_path(@product)
    end

=begin
    respond_to do |format|
                                   
      if @product.update_attributes(params[:product])
                
        flash[:notice] = 'Product was successfully updated.'
        format.html { redirect_to(go_to) and return }
        format.xml  { head :ok }
      else
        format.html { render go_to }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
      
    end #end respond_to
=end
                     
    if @product.update_attributes(params[:product])
              
      flash[:notice] = 'Product was successfully updated.'
      redirect_to(go_to) and return
      
    else
      render go_to and return
    end

    
    #failsafe
    flash[:error] = "There was somethink funky going on when you saved, maybe you should check your work."
    redirect_to(edit_admin_product_path(@product)) and return
    
  end #end action

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(admin_products_url) }
      format.xml  { head :ok }
    end
  end
end
