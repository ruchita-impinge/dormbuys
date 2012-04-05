class Admin::SiteBannersController < ApplicationController
  # GET /site_banners
  # GET /site_banners.xml
  def index
    @site_banners = SiteBanner.find(:all, :order => 'start_at desc').paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_banners }
    end
  end

  # GET /site_banners/1
  # GET /site_banners/1.xml
  def show
    @site_banner = SiteBanner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_banner }
    end
  end

  # GET /site_banners/new
  # GET /site_banners/new.xml
  def new
    @site_banner = SiteBanner.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_banner }
    end
  end

  # GET /site_banners/1/edit
  def edit
    @site_banner = SiteBanner.find(params[:id])
  end

  # POST /site_banners
  # POST /site_banners.xml
  def create
    @site_banner = SiteBanner.new(params[:site_banner])

    respond_to do |format|
      if @site_banner.save
        flash[:notice] = 'SiteBanner was successfully created.'
        format.html { redirect_to(admin_site_banners_path) }
        format.xml  { render :xml => @site_banner, :status => :created, :location => @site_banner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_banner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_banners/1
  # PUT /site_banners/1.xml
  def update
    @site_banner = SiteBanner.find(params[:id])

    respond_to do |format|
      if @site_banner.update_attributes(params[:site_banner])
        flash[:notice] = 'SiteBanner was successfully updated.'
        format.html { redirect_to(admin_site_banners_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_banner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_banners/1
  # DELETE /site_banners/1.xml
  def destroy
    @site_banner = SiteBanner.find(params[:id])
    @site_banner.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_banners_url) }
      format.xml  { head :ok }
    end
  end
end
