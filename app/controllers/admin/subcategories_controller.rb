class Admin::SubcategoriesController < Admin::AdminController
  
  
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
      if @subcategory.update_attributes(params[:subcategory])
        
        expire_general_caches
        
        flash[:notice] = 'Subcategory was successfully updated.'
        format.html { redirect_to(admin_subcategories_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
