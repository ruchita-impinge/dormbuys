class Admin::OrdersController < Admin::AdminController
  require 'admin_order_builder.rb'
  include AdminOrderBulder
  
#ajax methods
  def complete_processing
    @order = Order.find(params[:id])
    
    # update the inventory here
    ######
    # loop through the order line items and deduct the order line item QTY from the  ONHOLD quantity
    # for the product variation
    for item in @order.order_line_items

      variation = item.get_product_variation

      if variation

        #alter inventory 
        unless variation.product.drop_ship 
          new_onhold = variation.qty_on_hold - item.quantity
          variation.update_attributes(:qty_on_hold => new_onhold)
        end

      end #end variation

    end #end loop over order_line_items
    
    @order.skip_all_callbacks = true
    @order.processing = false
    @order.processed = true
    @order.save(false)
    
    render :update do |page|
      page << %( $("#processing_status").text("Processed"); )
      page << %( doneProcessing = true; )
      page << %( window.location.href = "#{admin_orders_path}" )
    end
    
  end #end method complete_processing


  def cancel_processing
    @order = Order.find(params[:id])
    @order.skip_all_callbacks = true
    @order.processing = false
    @order.processed = false
    @order.save(false)
    
    render :update do |page|
      page << %( $("#processing_status").text("Processing Canceled"); )
      page << %( doneProcessing = true; )
      page << %( window.location.href = "#{admin_orders_path}" )
    end
    
  end #end method cancel_processing


#ancillary method
  def kill_labels
    @order = Order.find(params[:id])
    if @order.kill_all_shipping_labels
      redirect_to "#{request.referrer}#shipping_info"
    else
      render :action => 'edit'
    end
  end #end method kill_labels


  def packing_list
    @order = Order.find(params[:id])
    render :partial => "shared/packing_list.html.erb", :layout => "packing_list"
  end #end method packing_list



  def apply_credit
    
    @order = Order.find(params[:id])
    
    if params[:credit][:credit_amount].to_money.cents <= 0
      @amount_error = true
    else
      begin
        @refund = Payment::PaymentManager.make_partial_refund(
          @order, 
          params[:credit][:credit_amount].to_money, 
          params[:credit][:credit_note])
      rescue Exception => e
          flash[:error] = "Error applying credit: #{e.message}"
          redirect_to edit_admin_order_path(@order) and return
      end
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
        flash[:notice] = "Drop ship emails have been sent to: #{@vendor.company_name}"
        redirect_to edit_admin_order_path(@order)
      else
        flash[:error] = "There was an error sending drop ship emails."
        flash.discard
        render :action => 'edit' and return
      end
      
    else
      
      if @order.send_drop_ship_emails
        flash[:notice] = "All drop ship emails have been sent"
        redirect_to edit_admin_order_path(@order)
      else
        flash[:error] = "There was an error sending drop ship emails."
        flash.discard
        render :action => 'edit' and return
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
          :order => 'order_date DESC',
          :limit => 300
          ).paginate :per_page => 10, :page => params[:page]
        
        
      when "email"
        @orders = Order.find(
          :all, 
          :conditions => [
            "email LIKE ? AND order_date >= ?", "%#{params[:search][:search_term]}%", date
          ],
          :order => 'order_date DESC',
          :limit => 300
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
          :order => 'order_date DESC',
          :limit => 300
          ).paginate :per_page => 10, :page => params[:page]
          
          
      when "full_name"
        first_name, last_name = params[:search][:search_term].split(" ")
        @orders = Order.find(
          :all, 
          :conditions => [
            "(((shipping_first_name LIKE ? AND shipping_last_name LIKE ?) OR (billing_first_name LIKE ? AND billing_last_name LIKE ?)) AND order_date >= ?)", 
            "%#{first_name}%", 
            "%#{last_name}%",
            "%#{first_name}%", 
            "%#{last_name}%",
            date
          ],
          :order => 'order_date DESC',
          :limit => 300
          ).paginate :per_page => 50, :page => params[:page]
    end
    
    render :action => :index
    
  end #end method search

    

  def index
    @orders = Order.find(:all, :include => [:order_line_items], :order => 'orders.order_date DESC', :limit => 300).paginate :per_page => 100, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders }
    end
  end



  def inline_order_list
    @orders = Order.find(:all, :include => [:order_line_items], :order => 'orders.order_date DESC', :limit => 300).paginate :per_page => 100, :page => params[:page]
    render :partial => "orders_list", :layout => false and return
  end #end method inline_order_list



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
    if request.path =~ /process/
      @order.skip_all_callbacks = true
      @order.processed = false
      @order.processing = true
      @order.save(false)
    else
      if @order.processing
        flash[:error] = "You can't update this order while it is being processed!!!"
        flash.discard
      end
    end
  end



  def create
    
    #params[:order][:credit_card_attributes] = params[:credit_card_attributes]
    
    @order = Order.new(params[:order])
    
    @order.client_ip_address = request.remote_ip
    @order.order_status_id = Order::ORDER_STATUS_WAITING
    @order.payment_info = "" if @order.grand_total.cents == 0


    render :update do |page|
      if @order.save
        flash[:notice] = 'Order was successfully created.'
        page << "window.location.href = '#{edit_admin_order_path(@order)}';"
      else
        msgs = @order.errors.full_messages.join('\n')
        page << "alert(\"Errors:\\n#{msgs}\")"
      end
    end


=begin
    respond_to do |format|
      if @order.save
        flash[:notice] = 'Order was successfully created.'
        format.html { redirect_to(edit_admin_order_path(@order)) }
        format.xml  { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
=end
    
  end #end create action



  def update
        
    @order = Order.find(params[:id])
    @order.skip_new_callbacks = true
    @order.attributes = params[:order]

    respond_to do |format|
      
      if @order.save
        flash[:notice] = 'Order was successfully updated.'
        format.html { 
          
          int_link = ""
          int_link = "#order_status" if params[:status_form]
          
          redirect_to("#{edit_admin_order_path(@order)}#{int_link}") 
        }
        format.xml  { head :ok }
      else
        
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
      
    end #end respond_to
  end #end action



  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(admin_orders_url) }
      format.xml  { head :ok }
    end
  end


end
