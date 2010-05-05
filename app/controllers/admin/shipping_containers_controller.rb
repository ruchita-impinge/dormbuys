class Admin::ShippingContainersController < ApplicationController
  # GET /shipping_containers
  # GET /shipping_containers.xml
  def index
    @shipping_containers = ShippingContainer.find(:all).paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shipping_containers }
    end
  end

  # GET /shipping_containers/1
  # GET /shipping_containers/1.xml
  def show
    @shipping_container = ShippingContainer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shipping_container }
    end
  end

  # GET /shipping_containers/new
  # GET /shipping_containers/new.xml
  def new
    @shipping_container = ShippingContainer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shipping_container }
    end
  end

  # GET /shipping_containers/1/edit
  def edit
    @shipping_container = ShippingContainer.find(params[:id])
  end

  # POST /shipping_containers
  # POST /shipping_containers.xml
  def create
    @shipping_container = ShippingContainer.new(params[:shipping_container])

    respond_to do |format|
      if @shipping_container.save
        flash[:notice] = 'ShippingContainer was successfully created.'
        format.html { redirect_to(admin_shipping_containers_path) }
        format.xml  { render :xml => @shipping_container, :status => :created, :location => @shipping_container }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shipping_container.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shipping_containers/1
  # PUT /shipping_containers/1.xml
  def update
    @shipping_container = ShippingContainer.find(params[:id])

    respond_to do |format|
      if @shipping_container.update_attributes(params[:shipping_container])
        flash[:notice] = 'ShippingContainer was successfully updated.'
        format.html { redirect_to(admin_shipping_containers_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shipping_container.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_containers/1
  # DELETE /shipping_containers/1.xml
  def destroy
    @shipping_container = ShippingContainer.find(params[:id])
    @shipping_container.destroy

    respond_to do |format|
      format.html { redirect_to(admin_shipping_containers_url) }
      format.xml  { head :ok }
    end
  end
end
