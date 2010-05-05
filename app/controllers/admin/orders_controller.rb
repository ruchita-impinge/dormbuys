class Admin::OrdersController < ApplicationController
  require 'admin_order_builder.rb'
  include AdminOrderBulder


  def search
    
    date = params[:search][:search_duration].to_i.days.ago
    
    case params[:search][:search_type]
      
      when "order_id"
        @orders = Order.find(
          :all, 
          :conditions => [
            "order_id LIKE ? AND order_date >= ?", "%#{params[:search][:search_term]}%", date
          ],
          :order => 'order_date DESC'
          ).paginate :per_page => 10, :page => params[:page]
        
        
      when "email"
        @orders = Order.find(
          :all, 
          :conditions => [
            "email LIKE ? AND order_date >= ?", "%#{params[:search][:search_term]}%", date
          ],
          :order => 'order_date DESC'
          ).paginate :per_page => 10, :page => params[:page]
          
          
      when "last_name"
        @orders = Order.find(
          :all, 
          :conditions => [
            "(shipping_last_name LIKE ? OR billing_last_name LIKE ?) AND order_date >= ?", 
            "%#{params[:search][:search_term]}%",
            "%#{params[:search][:search_term]}%",
            date
          ],
          :order => 'order_date DESC'
          ).paginate :per_page => 10, :page => params[:page]
          
          
      when "full_name"
        first_name, last_name = params[:search][:search_term].split(" ")
        @orders = Order.find(
          :all, 
          :conditions => [
            "((shipping_first_name LIKE ? AND shipping_last_name LIKE ?) OR ((billing_first_name LIKE ? AND billing_last_name LIKE ?)) AND order_date >= ?", 
            "%#{first_name}%", 
            "%#{last_name}%",
            "%#{first_name}%", 
            "%#{last_name}%",
            date
          ],
          :order => 'order_date DESC'
          ).paginate :per_page => 10, :page => params[:page]
    end
    
    render :action => :index
    
  end #end method search

    
  # GET /orders
  # GET /orders.xml
  def index
    @orders = Order.find(:all).paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.xml
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.xml
  def new
    @order = Order.new
    @order.order_id = Order.generate_uniq_order_id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.xml
  def create
    
    #params[:order][:credit_card_attributes] = params[:credit_card_attributes]
    
    @order = Order.new(params[:order])
    
    @order.client_ip_address = request.remote_ip
    @order.order_status_id = Order::ORDER_STATUS_WAITING
    @order.payment_info = "" if @order.grand_total.cents == 0


    respond_to do |format|
      if @order.save
        flash[:notice] = 'Order was successfully created.'
        format.html { redirect_to(admin_orders_path) }
        format.xml  { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.xml
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        flash[:notice] = 'Order was successfully updated.'
        format.html { redirect_to(admin_orders_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(admin_orders_url) }
      format.xml  { head :ok }
    end
  end
end
