class Admin::ShippingRatesTablesController < ApplicationController
  # GET /shipping_rates_tables
  # GET /shipping_rates_tables.xml
  def index
    redirect_to edit_admin_shipping_rates_table_path(ShippingRatesTable.first)
  end

  # GET /shipping_rates_tables/1
  # GET /shipping_rates_tables/1.xml
  def show
    redirect_to edit_admin_shipping_rates_table_path(ShippingRatesTable.first)
  end

  # GET /shipping_rates_tables/new
  # GET /shipping_rates_tables/new.xml
  def new
    redirect_to edit_admin_shipping_rates_table_path(ShippingRatesTable.first)
  end

  # GET /shipping_rates_tables/1/edit
  def edit
    @shipping_rates_table = ShippingRatesTable.first
  end

  # POST /shipping_rates_tables
  # POST /shipping_rates_tables.xml
  def create
    redirect_to edit_admin_shipping_rates_table_path(ShippingRatesTable.first)
  end

  # PUT /shipping_rates_tables/1
  # PUT /shipping_rates_tables/1.xml
  def update
    @shipping_rates_table = ShippingRatesTable.first

    respond_to do |format|
      if @shipping_rates_table.update_attributes(params[:shipping_rates_table])
        flash[:notice] = 'ShippingRatesTable was successfully updated.'
        format.html { redirect_to(admin_shipping_rates_tables_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shipping_rates_table.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_rates_tables/1
  # DELETE /shipping_rates_tables/1.xml
  def destroy
    flash[:error] = "Can't destroy the shipping rates table"
    redirect_to edit_admin_shipping_rates_table_path(ShippingRatesTable.first)
  end
  
end
