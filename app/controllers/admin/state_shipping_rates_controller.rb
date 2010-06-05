class Admin::StateShippingRatesController < ApplicationController
  # GET /state_shipping_rates
  # GET /state_shipping_rates.xml
  def index
    
    @state_shipping_rates = StateShippingRate.find(:all, :order => "state_id ASC").paginate :per_page => 50, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @state_shipping_rates }
    end
  end

  # GET /state_shipping_rates/1
  # GET /state_shipping_rates/1.xml
  def show
    @state_shipping_rate = StateShippingRate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @state_shipping_rate }
    end
  end

  # GET /state_shipping_rates/new
  # GET /state_shipping_rates/new.xml
  def new
    @state_shipping_rate = StateShippingRate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @state_shipping_rate }
    end
  end

  # GET /state_shipping_rates/1/edit
  def edit
    @state_shipping_rate = StateShippingRate.find(params[:id])
  end

  # POST /state_shipping_rates
  # POST /state_shipping_rates.xml
  def create
    @state_shipping_rate = StateShippingRate.new(params[:state_shipping_rate])

    respond_to do |format|
      if @state_shipping_rate.save
        flash[:notice] = 'StateShippingRate was successfully created.'
        format.html { redirect_to(admin_state_shipping_rates_path) }
        format.xml  { render :xml => @state_shipping_rate, :status => :created, :location => @state_shipping_rate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @state_shipping_rate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /state_shipping_rates/1
  # PUT /state_shipping_rates/1.xml
  def update
    @state_shipping_rate = StateShippingRate.find(params[:id])

    respond_to do |format|
      if @state_shipping_rate.update_attributes(params[:state_shipping_rate])
        flash[:notice] = 'StateShippingRate was successfully updated.'
        format.html { redirect_to(admin_state_shipping_rates_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @state_shipping_rate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /state_shipping_rates/1
  # DELETE /state_shipping_rates/1.xml
  def destroy
    @state_shipping_rate = StateShippingRate.find(params[:id])
    @state_shipping_rate.destroy

    respond_to do |format|
      format.html { redirect_to(admin_state_shipping_rates_url) }
      format.xml  { head :ok }
    end
  end
end
