class Admin::SearsTransmissionsController < ApplicationController
  # GET /sears_transmissions
  # GET /sears_transmissions.xml
  def index
    @sears_transmissions = SearsTransmission.find(:all).paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sears_transmissions }
    end
  end

  # GET /sears_transmissions/1
  # GET /sears_transmissions/1.xml
  def show
    @sears_transmission = SearsTransmission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sears_transmission }
    end
  end

  # GET /sears_transmissions/new
  # GET /sears_transmissions/new.xml
  def new
    @sears_transmission = SearsTransmission.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sears_transmission }
    end
  end

  # GET /sears_transmissions/1/edit
  def edit
    @sears_transmission = SearsTransmission.find(params[:id])
  end

  # POST /sears_transmissions
  # POST /sears_transmissions.xml
  def create
    @sears_transmission = SearsTransmission.new(params[:sears_transmission])

    respond_to do |format|
      if @sears_transmission.save
        flash[:notice] = 'SearsTransmission was successfully created.'
        format.html { redirect_to(admin_sears_transmissions_path) }
        format.xml  { render :xml => @sears_transmission, :status => :created, :location => @sears_transmission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sears_transmission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sears_transmissions/1
  # PUT /sears_transmissions/1.xml
  def update
    @sears_transmission = SearsTransmission.find(params[:id])

    respond_to do |format|
      if @sears_transmission.update_attributes(params[:sears_transmission])
        flash[:notice] = 'SearsTransmission was successfully updated.'
        format.html { redirect_to(admin_sears_transmissions_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sears_transmission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sears_transmissions/1
  # DELETE /sears_transmissions/1.xml
  def destroy
    @sears_transmission = SearsTransmission.find(params[:id])
    @sears_transmission.destroy

    respond_to do |format|
      format.html { redirect_to(admin_sears_transmissions_url) }
      format.xml  { head :ok }
    end
  end
end
