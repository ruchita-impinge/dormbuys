class Admin::OrderVendorsController < ApplicationController
  # GET /order_vendors
  # GET /order_vendors.xml
  def index
    @order_vendors = OrderVendor.find(:all).paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @order_vendors }
    end
  end

  # GET /order_vendors/1
  # GET /order_vendors/1.xml
  def show
    @order_vendor = OrderVendor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order_vendor }
    end
  end

  # GET /order_vendors/new
  # GET /order_vendors/new.xml
  def new
    @order_vendor = OrderVendor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order_vendor }
    end
  end

  # GET /order_vendors/1/edit
  def edit
    @order_vendor = OrderVendor.find(params[:id])
  end

  # POST /order_vendors
  # POST /order_vendors.xml
  def create
    @order_vendor = OrderVendor.new(params[:order_vendor])

    respond_to do |format|
      if @order_vendor.save
        flash[:notice] = 'OrderVendor was successfully created.'
        format.html { redirect_to(admin_order_vendors_path) }
        format.xml  { render :xml => @order_vendor, :status => :created, :location => @order_vendor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order_vendor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /order_vendors/1
  # PUT /order_vendors/1.xml
  def update
    @order_vendor = OrderVendor.find(params[:id])

    respond_to do |format|
      if @order_vendor.update_attributes(params[:order_vendor])
        flash[:notice] = 'OrderVendor was successfully updated.'
        format.html { redirect_to(admin_order_vendors_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order_vendor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /order_vendors/1
  # DELETE /order_vendors/1.xml
  def destroy
    @order_vendor = OrderVendor.find(params[:id])
    @order_vendor.destroy

    respond_to do |format|
      format.html { redirect_to(admin_order_vendors_url) }
      format.xml  { head :ok }
    end
  end
end
