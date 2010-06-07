class Admin::CouponsController < Admin::AdminController

  
  def search
    
    @coupons = Coupon.find(:all, :order => 'created_at DESC',
      :conditions => ["coupon_number LIKE ?", "%#{params[:search][:search_term]}%"]
      ).paginate :per_page => 10, :page => params[:page]
    
    render :action => :index
    
  end #end method search
  
  
  # GET /coupons
  # GET /coupons.xml
  def index
    @coupons = Coupon.find(:all, :order => 'created_at DESC').paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @coupons }
    end
  end

  # GET /coupons/1
  # GET /coupons/1.xml
  def show
    @coupon = Coupon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coupon }
    end
  end

  # GET /coupons/new
  # GET /coupons/new.xml
  def new
    @coupon = Coupon.new
    @coupon.expiration_date = Date.today + 1.year
    @coupon.generate_number

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @coupon }
    end
  end

  # GET /coupons/1/edit
  def edit
    @coupon = Coupon.find(params[:id])
  end

  # POST /coupons
  # POST /coupons.xml
  def create
    @coupon = Coupon.new(params[:coupon])

    respond_to do |format|
      if @coupon.save
        flash[:notice] = 'Coupon was successfully created.'
        format.html { redirect_to(admin_coupons_path) }
        format.xml  { render :xml => @coupon, :status => :created, :location => @coupon }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /coupons/1
  # PUT /coupons/1.xml
  def update
    @coupon = Coupon.find(params[:id])

    respond_to do |format|
      if @coupon.update_attributes(params[:coupon])
        flash[:notice] = 'Coupon was successfully updated.'
        format.html { redirect_to(admin_coupons_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.xml
  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy

    respond_to do |format|
      format.html { redirect_to(admin_coupons_url) }
      format.xml  { head :ok }
    end
  end
end
