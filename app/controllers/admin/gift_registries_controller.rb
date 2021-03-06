class Admin::GiftRegistriesController < Admin::AdminController

  def search
    
    term = params[:search][:search_term]
    
    case params[:search][:search_type]
      
      when "registry_number":
        @gift_registries = GiftRegistry.find(:all, 
          :conditions => ['registry_number LIKE ?', "%#{term}%"], 
          :order => 'event_date DESC').paginate :per_page => 20, :page => params[:page]
        
      when "owner_name":
        name_ids = User.find(:all, :conditions => ["last_name LIKE ?", "%#{term}%"]).collect{|u| u.id} if term.split(" ").length == 1
        name_ids = User.find(:all, :conditions => ["first_name LIKE ? AND last_name LIKE ?", "%#{term.split(" ")[0]}%", "%#{term.split(" ")[1]}%"]).collect{|u| u.id} if term.split(" ").length > 1
        name_ids << 0
        @gift_registries = GiftRegistry.find(:all, 
          :conditions => ["user_id IN (#{name_ids.join(",")})"], 
          :order => 'event_date DESC').paginate :per_page => 20, :page => params[:page]
        
      when "owner_email":
        email_ids = User.find(:all, :conditions => ["email LIKE ?", "%#{term}%"]).collect{|u| u.id}
        email_ids << 0
        @gift_registries = GiftRegistry.find(:all, 
          :conditions => ["user_id IN (#{email_ids.join(",")})"], 
          :order => 'event_date DESC').paginate :per_page => 20, :page => params[:page]
        
      when "registered_name":
        names = GiftRegistryName.find(:all, :conditions => ["last_name LIKE ?", "%#{term}%"]) if term.split(" ").length == 1
        names = GiftRegistryName.find(:all, :conditions => ["first_name LIKE ? AND last_name LIKE ?", "%#{term.split(" ")[0]}%", "%#{term.split(" ")[1]}%"]) if term.split(" ").length > 1
        names << GiftRegistryName.new(:id => 0)
        @gift_registries = GiftRegistry.find(:all, 
          :conditions => ['id IN (?)', names.collect{|n| n.gift_registry_id}], 
          :order => 'event_date DESC').paginate :per_page => 20, :page => params[:page]
    
  
    end #end case
    
    render :action => :index
    
  end #end method search



  
  def auto_complete_for_product_product_name

    product_name = params[:product_variation_search_term]

    @products = Product.find(:all, 
      :conditions => [ "LOWER(#{params[:method]}) LIKE ?",
      '%' + product_name.downcase + '%'], 
      :order => "#{params[:method]} ASC",
      :limit => 10)
    @variations = @products.collect {|p| p.available_variations }.flatten

    render :partial => 'auto_complete_list', :object => @variations
  end
  
  
  # GET /gift_registries
  # GET /gift_registries.xml
  def index
    @gift_registries = GiftRegistry.find(:all, :order => 'event_date DESC').paginate :per_page => 20, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @gift_registries }
    end
  end

  # GET /gift_registries/1
  # GET /gift_registries/1.xml
  def show
    @gift_registry = GiftRegistry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @gift_registry }
    end
  end

  # GET /gift_registries/new
  # GET /gift_registries/new.xml
  def new
    @gift_registry = GiftRegistry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @gift_registry }
    end
  end

  # GET /gift_registries/1/edit
  def edit
    @gift_registry = GiftRegistry.find(params[:id])
  end

  # POST /gift_registries
  # POST /gift_registries.xml
  def create
    @gift_registry = GiftRegistry.new(params[:gift_registry])

    respond_to do |format|
      if @gift_registry.save
        flash[:notice] = 'GiftRegistry was successfully created.'
        format.html { redirect_to(admin_gift_registries_path) }
        format.xml  { render :xml => @gift_registry, :status => :created, :location => @gift_registry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @gift_registry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /gift_registries/1
  # PUT /gift_registries/1.xml
  def update
    @gift_registry = GiftRegistry.find(params[:id])

    respond_to do |format|
      if @gift_registry.update_attributes(params[:gift_registry])
        flash[:notice] = 'GiftRegistry was successfully updated.'
        format.html { redirect_to(admin_gift_registries_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @gift_registry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /gift_registries/1
  # DELETE /gift_registries/1.xml
  def destroy
    @gift_registry = GiftRegistry.find(params[:id])
    @gift_registry.destroy

    respond_to do |format|
      format.html { redirect_to(admin_gift_registries_url) }
      format.xml  { head :ok }
    end
  end
end
