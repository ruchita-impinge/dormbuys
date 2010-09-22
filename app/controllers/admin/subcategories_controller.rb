class Admin::SubcategoriesController < Admin::AdminController
  
  
  def auto_complete_for_sears_tpc_tree

    search_term = params[:third_party_cat_search_term]

    @cats = ThirdPartyCategory.find(:all, 
      :conditions => ["owner = ? AND LOWER(#{params[:method]}) LIKE ?",
      ThirdPartyCategory::SEARS,
      '%' + search_term.downcase + '%'], 
      :order => "#{params[:method]} ASC",
      :limit => 20)

    render :partial => 'tpc_auto_complete_list', :object => @cats
  end #end auto_complete_for_sears_tpc_tree
  
  
  def auto_complete_for_lnt1_tpc_tree
    search_term = params[:third_party_cat_search_term]

    @cats = ThirdPartyCategory.find(:all, 
      :conditions => ["owner = ? AND LOWER(#{params[:method]}) LIKE ?",
      ThirdPartyCategory::LNT,
      '%' + search_term.downcase + '%'], 
      :order => "#{params[:method]} ASC",
      :limit => 20)

    render :partial => 'tpc_auto_complete_list', :object => @cats
  end #end auto_complete_for_lnt1_tpc_tree
  
  
  def auto_complete_for_lnt2_tpc_tree
    search_term = params[:third_party_cat_search_term]

    @cats = ThirdPartyCategory.find(:all, 
      :conditions => ["owner = ? AND LOWER(#{params[:method]}) LIKE ?",
      ThirdPartyCategory::LNT2,
      '%' + search_term.downcase + '%'], 
      :order => "#{params[:method]} ASC",
      :limit => 20)

    render :partial => 'tpc_auto_complete_list', :object => @cats
  end #end auto_complete_for_lnt2_tpc_tree
  
  
  
  
  
  
  
  def lnt1
    @categories = Category.all(:include => [:subcategories => {:all_children, :third_party_categories}])  
    @third_party = ThirdPartyCategory::LNT
    render 'mapper.html.erb'
  end #end method lnt1
  
  def lnt2
    @categories = Category.all(:include => [:subcategories => {:all_children, :third_party_categories}])  
    @third_party = ThirdPartyCategory::LNT2
    render 'mapper.html.erb'
  end #end method lnt2
  
  
  def save_map
    params[:subcategory][:id].each_with_index do |val,i|
      id = val.to_i
      third_cat_id = params[:subcategory][:third_party_category_ids][i].to_i
      
      if id != 0 && third_cat_id != 0
        
        #get objects for the sub cat & the thrid party cat
        s = Subcategory.find(id)
        third_cat = ThirdPartyCategory.find(third_cat_id)
        
        #get a collection of third cats that aren't of the same owner as the one we want to set
        thirds_w_other_owners = s.third_party_categories.reject {|x| x if x.owner == third_cat.owner }
        
        #set the third cats to the others owners and this one.  That way we maintain that 
        # we only have 1 third party cat per third party
        s.third_party_category_ids = thirds_w_other_owners.collect(&:id) | [third_cat_id]
        
      end
    end
    
    flash[:notice] = "Category mapping has successfully been updated"
    @map_saved = true
    render 'mapper.html.erb'
    
  end #end method save_map
  
  
  def lnt_map
    @subcategory = Subcategory.find(params[:id], :include => [:third_party_categories])
  end #end method lnt_map
  
  def lnt2_map
    @subcategory = Subcategory.find(params[:id], :include => [:third_party_categories])
  end #end method lnt2_map
  
  def sears_map
    @subcategory = Subcategory.find(params[:id], :include => [:third_party_categories])
  end #end method sears_map

  
  # GET /subcategories
  # GET /subcategories.xml
  def index
    #@subcategories = Subcategory.find(:all).paginate :per_page => 10, :page => params[:page]
    @categories = Category.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subcategories }
    end
  end

  # GET /subcategories/1
  # GET /subcategories/1.xml
  def show
    @subcategory = Subcategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subcategory }
    end
  end

  # GET /subcategories/new
  # GET /subcategories/new.xml
  def new
    @subcategory = Subcategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subcategory }
    end
  end

  # GET /subcategories/1/edit
  def edit
    @subcategory = Subcategory.find(params[:id])
  end

  # POST /subcategories
  # POST /subcategories.xml
  def create
    @subcategory = Subcategory.new(params[:subcategory])

    respond_to do |format|
      if @subcategory.save
        
        expire_general_caches
        
        flash[:notice] = 'Subcategory was successfully created.'
        format.html { redirect_to(admin_subcategories_path) }
        format.xml  { render :xml => @subcategory, :status => :created, :location => @subcategory }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subcategory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subcategories/1
  # PUT /subcategories/1.xml
  def update
    @subcategory = Subcategory.find(params[:id])

    respond_to do |format|
      
      if request.referrer =~ /lnt_map/ || request.referrer =~ /lnt2_map/ || request.referrer =~ /sears_map/
        third_id = params[:subcategory][:third_party_category_ids].first.to_i
        tpc = ThirdPartyCategory.find(third_id)
        unless tpc.blank?
          existing_tpcs = @subcategory.third_party_categories.reject {|c| c if c.owner == tpc.owner}
          existing_tpc_ids = existing_tpcs.collect {|c| c.id }
          existing_tpc_ids << tpc.id
          @subcategory.third_party_category_ids = existing_tpc_ids
          updated = true
        else
          updated = false
          @subcategory.errors.add_to_base("Third Party Category was not found")
        end
      else
        updated = @subcategory.update_attributes(params[:subcategory])
      end #end 3rd party mapping
      
      if updated
        
        expire_general_caches
        
        #setup the end action for redirects & renders
        if params[:end_action]
          go_to = {:action => params[:end_action].to_sym, :id => @subcategory }
          error_action = params[:end_action]
        else
          go_to = edit_admin_subcategory_path(@subcategory)
          error_action = "edit"
        end
        
        
        flash[:notice] = 'Subcategory was successfully updated.'
        #format.html { redirect_to(admin_subcategories_path) }
        format.html { redirect_to(edit_admin_subcategory_path(@subcategory))}
        format.xml  { head :ok }
      else
        #format.html { render :action => "edit" }
        format.html { render :action => error_action }
        format.xml  { render :xml => @subcategory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subcategories/1
  # DELETE /subcategories/1.xml
  def destroy
    @subcategory = Subcategory.find(params[:id])
    @subcategory.destroy
    
    expire_general_caches

    respond_to do |format|
      format.html { redirect_to(admin_subcategories_url) }
      format.xml  { head :ok }
    end
  end
end
