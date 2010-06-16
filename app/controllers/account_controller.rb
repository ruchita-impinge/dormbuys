class AccountController < ApplicationController

  before_filter :login_required, :except => [:login, :submit_login, :logout, :user_signup, :forgot_password, :submit_forgot_password]
  
  layout 'front_short_banner'
  
  
  def ssl_required?
    true
  end
  
  
  def index
    @page_title = "Account"
    unless logged_in?
      redirect_to account_login_path and return
    end
  end
  
  
  
  def forgot_password
  end #end method forgot_password
  
  def submit_forgot_password
    
    unless request.post? || request.put?
      redirect_to forgot_password_path
    end
    
    @user = User.find_by_email(params[:login][:email])
    
    if @user
      
      @user.send_new_password
      
      flash[:notice] = "Your password has been reset and emailed to: #{@user.email}"
      redirect_to forgot_password_path
    else
      flash[:error] = "User could not be found"
      redirect_to forgot_password_path
    end
    
  end #end method submit_forgot_password
  
  
  def login
    
    if logged_in?
      if current_user.has_role?("admin")
        redirect_to(admin_products_path) and return
      else
        redirect_to(account_path) and return
      end
    end
    
    @page_title = "Account Login"
    @user = User.new
  end #end method login
  

  def submit_login
    @page_title = "Account Login"
    @user = User.new
    logout_keeping_session!
    user = User.authenticate(params[:login][:email], params[:login][:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:login][:remember] == "1")
      handle_remember_cookie! new_cookie_flag
      
      if user.has_role?("admin")
        redirect_back_or_default(admin_products_path)
      else
        redirect_back_or_default(account_path)
      end
      
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @email       = params[:login][:email]
      @remember_me = params[:login][:remember]
      redirect_to login_path
    end
  end #end method submit_login
  
  
  def user_signup
        
    @page_title = "Account Login"
    @user = User.new(params[:user])
    @user.role_ids = [1]
    
    if @user.save
      logout_keeping_session!
      self.current_user = @user
      
      flash[:notice] = "Thanks for signing up!"
      redirect_to account_path
    else
      render :action => 'login'
    end
    
  end #end method user_signup
  

  def logout
    @page_title = "Logout | Account"
    if logged_in?
      logout_killing_session!
      flash[:notice] = "You have been logged out."
      redirect_back_or_default(account_logout_path)
    end
  end #end method logout
  
  
  
  
  
  def gift_card
    @page_title = "Gift Card | Account"
    @gift_card = GiftCard.new
  end #end method gift_card
  
  
  def gift_card_submit
    @page_title = "Gift Card | Account"
    @gift_card = GiftCard.find_by_giftcard_number(params[:gift_card][:giftcard_number])
    
    if @gift_card
      if @gift_card.giftcard_pin == params[:gift_card][:giftcard_pin]
        render :action => "gift_card"
      else
        flash[:error] = "Invalid pin number"
        redirect_to account_gift_card_path and return
      end
    else
      flash[:error] = "Gift Card not found"
      redirect_to account_gift_card_path and return
    end

  end #end method gift_card_submit
  
  
  
  
  
  def password
    @page_title = "Update Password | Account"
    @user = current_user
  end #end method password
  
  
  def update_password
    @page_title = "Update Password | Account"
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Password successfully updated"
      redirect_to account_password_path
    else
      render :action => "password"
    end
  end #end method update_password
  
  
  
  
  def email
    @user = current_user
    found = EmailListClient.find_by_email(current_user.email)
    if found
      render :action => "email_edit"
    else
      render :action => "email_subscribe"
    end
  end #end method email
  
  
  def email_subscribe
    @user = current_user
    found = EmailListClient.find_by_email(current_user.email)
    if found
      redirect_to account_email_edit_path
    else
      EmailListClient.create(:email => current_user.email)
      flash[:notice] = "Thanks for signing up!"
      redirect_to account_email_edit_path
    end
  end #end method email_subscribe
  

  def email_edit
    @user = current_user
    
    if request.post? || request.put?
      
      old_email = current_user.email
      found = EmailListClient.find_by_email(old_email)
      
      if @user.update_attributes(params[:user])
        
        found.update_attributes(:email => @user.email)
        
        flash[:notice] = "Your email was successfully updated to '#{@user.email}'"
        redirect_to account_email_edit_path        
      end
      
    elsif params[:remove]
      found = EmailListClient.find_by_email(current_user.email)
      found.destroy
      flash[:notice] = "Your address was successfully removed"
      redirect_to account_email_path
    end
    
  end #end method email_unsubscribe
  
  
  
  
  def billing
    @page_title = "Billing &amp; Shipping"
    @user = current_user
  end #end method billing


  def billing_edit
    @page_title = "Billing &amp; Shipping"
    @user = current_user
  end #end method billing_edit
  
  
  def billing_update
    @page_title = "Billing &amp; Shipping"
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Billing &amp; Shipping information successfully updated"
      redirect_to account_billing_path
    else
      render :action => "billing_edit"
    end
  end #end method billing_update

  
  
  
  def orders
    @page_title = "Current Orders"
    @orders = current_user.orders.find(:all, :conditions => {:order_status_id => Order::ORDER_STATUS_PENDING})
  end #end method orders
  
  
  def all_orders
    @page_title = "All Orders"
    
    if params[:view_all]
      @view_all = true
      @orders = current_user.orders
    else
      @orders = current_user.orders.paginate :per_page => 4, :page => params[:page]
    end
  end #end method all_orders
  
  
  def view_order  
    @page_title = "View Order"
    @order = current_user.orders.find(params[:order_id])
  end #end method view_order
  
  
  def order_invoice
    @order = current_user.orders.find(params[:order_id])
    render :partial => "shared/packing_list.html.erb", :layout => "packing_list"
  end #end method order_invoice
  
  
  
  
  def wish_list
    @page_title = "Wish List"
    @wish_list = current_user.wish_list
    @items = @wish_list.wish_list_items
    @items.reject! {|i| i if i.product_variation.blank? }
    
    find_cart
    
    #routine to move items from the cart to the wish list
    wl_items = @cart.wish_list_items
    wl_items.each do |wl_cart_item|
      wl_item = @wish_list.wish_list_items.build
      wl_item.product_variation_id = wl_cart_item.product_variation_id
      wl_item.wish_qty = wl_cart_item.quantity
      wl_item.got_qty = 0
      wl_item.product_options = wl_cart_item.pov_ids
      wl_item.product_as_options = wl_cart_item.paov_ids
      wl_item.save(false)
      wl_cart_item.destroy
    end
    
    
    #detect if sort was run
    unless params[:options].blank?

      if params[:options][:show] != "all"
        
        if params[:options][:show] == "fulfilled"
          @items.reject! {|i| i unless i.fulfilled? }
        elsif params[:options][:show] == "unfulfilled"
          @items.reject! {|i| i if i.fulfilled? }
        end
        
      end
        
        
      if params[:options][:sort_by] == "name"
        @items.sort! {|x,y| x.product_variation.full_title <=> y.product_variation.full_title}
      elsif params[:options][:sort_by] == "price"
        @items.sort! {|x,y| x.price <=> y.price}
      elsif params[:options][:sort_by] == "created_at"
        @items.sort! {|x,y| x.created_at <=> y.created_at}
      end
        
        
    end #end if no options
    
  end #end method wish_list
  
  
  def update_wish_list
    @page_title = "Wish List"
    @wish_list = current_user.wish_list
    
    if @wish_list.update_attributes(params[:wish_list])
      flash[:notice] = "Wish list successfully updated"
      redirect_to account_wish_list_path and return
    else
      
      raise "test"
      
      render :action => "wish_list"
    end
    
  end #end method update_wish_list
  
  

####################################
# Gift Reg actions, this shoud
# probably have its own controller
####################################  
  
  def gift_registries
    @page_title = "Gift Registry"
    @gift_registries = current_user.gift_registries.all
  end #end method gift_registries
  
  
  def select_registry_to_add_to
    @page_title = "Gift Registry"
    @gift_registries = current_user.gift_registries.all
    
    if @gift_registries.size == 1
      find_cart
      @cart.gift_registry_items.each do |cart_item|
        @gift_registries.first.add_cart_item(cart_item)
      end
      flash[:notice] = "Product was successfully added to registry"
      redirect_to account_view_gift_registry_path(@gift_registries.first)
    end
    
  end #end method select_registry_to_add_to
  
  
  def add_to_registry
    @page_title = "Gift Registry"
    @gift_registry = current_user.gift_registries.find(params[:id])
    
    find_cart
    @cart.gift_registry_items.each do |cart_item|
      @gift_registry.add_cart_item(cart_item)
    end
    flash[:notice] = "Product was successfully added to registry"
    redirect_to account_view_gift_registry_path(@gift_registry)
  end #end method add_to_registry
  
  
  def view_gift_registry
    @page_title = "Gift Registry"
    @gift_registry = current_user.gift_registries.find(params[:id])
    
    
    @sort_cats = [["All Categories", 0]]
    @gift_registry.gift_registry_items.each do |item|
      if item.product_variation
        item.product_variation.product.subcategories.each do |sub|
          @sort_cats << [sub.category.name, sub.category.id]
        end
      end
    end
    
    @sort_cats.uniq!
    @sort_cats.unshift(["All Categories", 0])
    
    @items = @gift_registry.gift_registry_items
    
    #detect if sort was run
    unless params[:options].blank?
      
      if params[:options][:show_price] != "all"
        
        low, high = params[:options][:show_price].split("-")
        @items.reject! {|i| i unless i.price >= low.to_money && i.price <= high.to_money }
        
      end
        
        
      if params[:options][:show_cat].to_i != 0
        @items.reject! {|i| i unless i.product_variation && i.product_variation.product.subcategories.collect(&:category_id).include?(params[:options][:show_cat].to_i) }
      end
        
        
      if params[:options][:sort] == "product_name"
        @items.sort! {|x,y| x.product_variation.full_title <=> y.product_variation.full_title}
      elsif params[:options][:sort] == "price"
        @items.sort! {|x,y| x.price <=> y.price}
      end
        
        
    end #end if no options
    
    
    
  end #end method view_gift_registry
  
  
  #ajax method
  def add_registry_name
    @name = GiftRegistryName.new(:first_name => params[:fname], :last_name => params[:lname], :email => params[:email])
    render :update do |page|
      if @name.valid?
        page.insert_html :bottom, "registry_names_box", :partial => "gift_registry_name", :object => @name
        page << %($("#name_fname").val(""))
        page << %($("#name_lname").val(""))
        page << %($("#name_email").val(""))
      else
        msgs = @name.errors.full_messages.join('\n')
        page << "alert(\"Errors:\\n#{msgs}\")"
      end
    end
  end #end method add_registry_name
  
  
  def new_gift_registry
    @page_title = "Gift Registry"
    @gift_registry = current_user.gift_registries.build
    @name = @gift_registry.gift_registry_names.build
    
    @gift_registry.shipping_address     = current_user.shipping_address
    @gift_registry.shipping_address2    = current_user.shipping_address2
    @gift_registry.shipping_city        = current_user.shipping_city
    @gift_registry.shipping_state_id    = current_user.shipping_state_id
    @gift_registry.shipping_zip_code    = current_user.shipping_zipcode
    @gift_registry.shipping_country_id  = current_user.shipping_country_id
    @gift_registry.shipping_phone       = current_user.shipping_phone
    
    @name.first_name = current_user.first_name
    @name.last_name = current_user.last_name
    @name.email = current_user.email
    
  end #end method new_gift_registry
  
  
  def create_gift_registry
    @page_title = "Gift Registry"
    @gift_registry = current_user.gift_registries.build(params[:gift_registry])
    if @gift_registry.save
      if pending_registry_item?
        flash[:notice] = "Gift Registry successfully created, now select the registry to add your item to"
        redirect_to account_select_registry_path
      else
        flash[:notice] = "Gift Registry successfully created"
        redirect_to account_gift_registries_path
      end
    else
      render :action => "new_gift_registry"
    end
  end #end method create_gift_registry
  
  
  def edit_gift_registry
    @page_title = "Gift Registry"
    @gift_registry = current_user.gift_registries.find(params[:id])
  end #end method edit_gift_registry
  
  
  def update_gift_registry
    @page_title = "Gift Registry"
    @gift_registry = current_user.gift_registries.find(params[:id])
    
    if @gift_registry.update_attributes(params[:gift_registry])
      flash[:notice] = "Gift Registry was successfully updated"
      redirect_to account_gift_registries_path
    else
      render :action => "edit_gift_registry"
    end
    
  end #end method update_gift_registry
  
  
  def destroy_gift_registry
    @gift_registry = current_user.gift_registries.find(params[:id])
    @gift_registry.destroy
    
    flash[:notice] = "Gift Registry was succssfully deleted"
    redirect_to account_gift_registries_path
  end #end method destroy_gift_registry


  #convenience method
  def pending_registry_item?
    find_cart
    @cart.gift_registry_items.size > 0
  end #end method pending_registry_item?

end
