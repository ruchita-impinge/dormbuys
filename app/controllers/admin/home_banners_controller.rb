class Admin::HomeBannersController < Admin::AdminController
  
  # GET /home_banners
  # GET /home_banners.xml
  def index
    @home_banners = HomeBanner.find(:all).paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @home_banners }
    end
  end

  # GET /home_banners/1
  # GET /home_banners/1.xml
  def show
    @home_banner = HomeBanner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @home_banner }
    end
  end

  # GET /home_banners/new
  # GET /home_banners/new.xml
  def new
    @home_banner = HomeBanner.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @home_banner }
    end
  end

  # GET /home_banners/1/edit
  def edit
    @home_banner = HomeBanner.find(params[:id])
  end

  # POST /home_banners
  # POST /home_banners.xml
  def create
    @home_banner = HomeBanner.new(params[:home_banner])

    respond_to do |format|
      if @home_banner.save
        
        expire_home_banner_caches
        
        flash[:notice] = 'Home Banner was successfully created.'
        format.html { redirect_to(admin_home_banners_path) }
        format.xml  { render :xml => @home_banner, :status => :created, :location => @home_banner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @home_banner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /home_banners/1
  # PUT /home_banners/1.xml
  def update
    @home_banner = HomeBanner.find(params[:id])

    respond_to do |format|
      if @home_banner.update_attributes(params[:home_banner])
        
        expire_home_banner_caches
        
        flash[:notice] = 'Home Banner was successfully updated.'
        format.html { redirect_to(admin_home_banners_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @home_banner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /home_banners/1
  # DELETE /home_banners/1.xml
  def destroy
    @home_banner = HomeBanner.find(params[:id])
    
    if @home_banner.is_main
      flash[:error] = "Can't delete the main banner, set another as main first"
      redirect_to(admin_home_banners_url) and return
    end
    
    @home_banner.destroy

    respond_to do |format|
      format.html { redirect_to(admin_home_banners_url) }
      format.xml  { head :ok }
    end
  end
end
