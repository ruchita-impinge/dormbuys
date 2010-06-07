class Admin::OrdersController < Admin::AdminController
  require 'admin_order_builder.rb'
  include AdminOrderBulder


  def packing_list
    @order = Order.find(params[:id])
    render :partial => "shared/packing_list.html.erb", :layout => "packing_list"
  end #end method packing_list



  def apply_credit
    
    @order = Order.find(params[:id])
    
    if params[:credit][:credit_amount].to_money.cents <= 0
      @amount_error = true
    else
      @refund = Payment::PaymentManager.make_partial_refund(
        @order, 
        params[:credit][:credit_amount].to_money, 
        params[:credit][:credit_note])
    end
    
    
    if @amount_error
      flash[:error] = "Error: please check the amount of your credit"
    elsif @refund.success
      flash[:notice] = "Credit was successfully applied"
    else
      flash[:error] = "Error applying credit, see the order credit box for more details"
    end
    
    redirect_to edit_admin_order_path(@order)
    
  end #end method apply_credit



  def notify_dropship
    @order = Order.find(params[:id])
          
    if params[:vendor]
      @vendor = Vendor.find(params[:vendor_id])
      
      if @order.send_individual_drop_ship_emails(@vendor)
        flash[:notice] = "Drop ship emails are now being sent to #{@vendor.company_name}"
        redirect_to edit_admin_order_path(@order)
      else
        flash[:error] = "There was an error sending drop ship emails to #{@vendor.company_name} contact support."
        redirect_to edit_admin_order_path(@order)
      end
      
    else
      
      if @order.send_drop_ship_emails
        flash[:notice] = "All drop ship emails are now being sent"
        redirect_to edit_admin_order_path(@order)
      else
        flash[:error] = "There was an error sending drop ship emails, contact support."
        redirect_to edit_admin_order_path(@order)
      end
      
    end
    
  end #end method notify_dropship



  def edit_shipping
    @order = Order.find(params[:id])
    
    @order.send_later(:kill_all_shipping_labels)
    
    render :update do |page|
      page.replace_html "shipping_address", :partial => "edit_shipping_addy"
    end
  end #end method edit_shipping



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

    

  def index
    @orders = Order.find(:all, :order => 'order_date DESC').paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders }
    end
  end



  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end



  def new
    @order = Order.new
    @order.order_id = Order.generate_uniq_order_id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order }
    end
  end



  def edit
    @order = Order.find(params[:id])
  end



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



  def update
        
    @order = Order.find(params[:id])
    @order.attributes = params[:order]

    respond_to do |format|
      if @order.save
        
        flash[:notice] = 'Order was successfully updated.'
        format.html { redirect_to(edit_admin_order_path(@order)) }
        
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end



  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(admin_orders_url) }
      format.xml  { head :ok }
    end
  end


end
