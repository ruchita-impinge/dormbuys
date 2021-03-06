class Admin::WishListsController < Admin::AdminController


  def search
    
    term = params[:search][:search_term]
    
    case params[:search][:search_type]

      when "owner_name":
        name_ids = User.find(:all, :conditions => ["last_name LIKE ?", "%#{term}%"]).collect{|u| u.id} if term.split(" ").length == 1
        name_ids = User.find(:all, :conditions => ["first_name LIKE ? AND last_name LIKE ?", "%#{term.split(" ")[0]}%", "%#{term.split(" ")[1]}%"]).collect{|u| u.id} if term.split(" ").length > 1
        name_ids << 0
        @wish_lists = WishList.find(:all, 
          :conditions => ["user_id IN (#{name_ids.join(",")})"]).paginate :per_page => 20, :page => params[:page]
          
      when "owner_email":
        email_ids = User.find(:all, :conditions => ["email LIKE ?", "%#{term}%"]).collect{|u| u.id}
        email_ids << 0
        @wish_lists = WishList.find(:all, 
          :conditions => ["user_id IN (#{email_ids.join(",")})"]).paginate :per_page => 20, :page => params[:page]
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
  
  
  # GET /wish_lists
  # GET /wish_lists.xml
  def index
    @wish_lists = WishList.find(:all, :order => 'created_at DESC').paginate :per_page => 20, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @wish_lists }
    end
  end

  # GET /wish_lists/1
  # GET /wish_lists/1.xml
  def show
    @wish_list = WishList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @wish_list }
    end
  end

  # GET /wish_lists/new
  # GET /wish_lists/new.xml
  def new
    @wish_list = WishList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wish_list }
    end
  end

  # GET /wish_lists/1/edit
  def edit
    @wish_list = WishList.find(params[:id])
  end

  # POST /wish_lists
  # POST /wish_lists.xml
  def create
    @wish_list = WishList.new(params[:wish_list])

    respond_to do |format|
      if @wish_list.save
        flash[:notice] = 'WishList was successfully created.'
        format.html { redirect_to(admin_wish_lists_path) }
        format.xml  { render :xml => @wish_list, :status => :created, :location => @wish_list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wish_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /wish_lists/1
  # PUT /wish_lists/1.xml
  def update
    @wish_list = WishList.find(params[:id])

    respond_to do |format|
      if @wish_list.update_attributes(params[:wish_list])
        flash[:notice] = 'WishList was successfully updated.'
        format.html { redirect_to(admin_wish_lists_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wish_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /wish_lists/1
  # DELETE /wish_lists/1.xml
  def destroy
    @wish_list = WishList.find(params[:id])
    @wish_list.destroy

    respond_to do |format|
      format.html { redirect_to(admin_wish_lists_url) }
      format.xml  { head :ok }
    end
  end
end
