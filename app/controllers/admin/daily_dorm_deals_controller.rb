class Admin::DailyDormDealsController < Admin::AdminController
  
  
  def auto_complete_for_product_product_name

    if params[:product_variation_search_term]
      product_name = params[:product_variation_search_term]
      is_variation = true
    elsif params[:product_search_term]
      product_name = params[:product_search_term]
      is_variation = false
    end


    @products = Product.find(:all, 
      :conditions => [ "LOWER(#{params[:method]}) LIKE ?",
      '%' + product_name.downcase + '%'], 
      :order => "#{params[:method]} ASC",
      :limit => 10)
    
    
    if is_variation
      @variations = @products.collect {|p| p.product_variations }.flatten
      render :partial => 'auto_complete_variation_list', :object => @variations
    else
      render :partial => 'auto_complete_product_list', :object => @products
    end
    
  end #end auto_complete_for_product_product_name
  
  
  
  
  # GET /daily_dorm_deals
  # GET /daily_dorm_deals.xml
  def index
    @daily_dorm_deals = DailyDormDeal.find(:all, :order => 'start_time DESC').paginate :per_page => 25, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @daily_dorm_deals }
    end
  end

  # GET /daily_dorm_deals/1
  # GET /daily_dorm_deals/1.xml
  def show
    @daily_dorm_deal = DailyDormDeal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @daily_dorm_deal }
    end
  end

  # GET /daily_dorm_deals/new
  # GET /daily_dorm_deals/new.xml
  def new
    @daily_dorm_deal = DailyDormDeal.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @daily_dorm_deal }
    end
  end

  # GET /daily_dorm_deals/1/edit
  def edit
    @daily_dorm_deal = DailyDormDeal.find(params[:id])
  end

  # POST /daily_dorm_deals
  # POST /daily_dorm_deals.xml
  def create
    @daily_dorm_deal = DailyDormDeal.new(params[:daily_dorm_deal])

    respond_to do |format|
      if @daily_dorm_deal.save
        flash[:notice] = 'DailyDormDeal was successfully created.'
        format.html { redirect_to(admin_daily_dorm_deals_path) }
        format.xml  { render :xml => @daily_dorm_deal, :status => :created, :location => @daily_dorm_deal }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @daily_dorm_deal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /daily_dorm_deals/1
  # PUT /daily_dorm_deals/1.xml
  def update
    @daily_dorm_deal = DailyDormDeal.find(params[:id])

    respond_to do |format|
      if @daily_dorm_deal.update_attributes(params[:daily_dorm_deal])
        flash[:notice] = 'DailyDormDeal was successfully updated.'
        format.html { redirect_to(admin_daily_dorm_deals_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @daily_dorm_deal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_dorm_deals/1
  # DELETE /daily_dorm_deals/1.xml
  def destroy
    @daily_dorm_deal = DailyDormDeal.find(params[:id])
    @daily_dorm_deal.destroy

    respond_to do |format|
      format.html { redirect_to(admin_daily_dorm_deals_url) }
      format.xml  { head :ok }
    end
  end
end
