class CartController < ApplicationController
  
  ssl_required :login, :submit_login, :user_signup, :billing_shipping, 
    :save_billing_shipping, :review, :confirm
  
  layout "front_short_banner"
  
  #view cart
  def index
    @page_title = "View Cart"
    find_cart
  end
  
  
  #add item to cart
  def add
    if params[:cart_item][:variation_id].blank?
      flash[:error] = "Use the first drop down list to select the product variation"
      redirect_to request.referrer and return
    end
    
    if params[:cart_item][:qty].blank?
      flash[:error] = "You must specify a quantity"
      redirect_to request.referrer and return
    end
    
    find_cart
    @cart.add(params[:cart_item])
    
    
    if params[:cart_item][:is_wish_list_item].to_i == 1
      
      if logged_in?
        flash[:notice] = "The item was successfully added to your wish list"
      else
        flash[:notice] = "Login or create an account to add the product to your wish list"
      end
      redirect_to account_wish_list_path and return
      
    elsif params[:cart_item][:is_gift_registry_item].to_i == 1
      
      unless logged_in?
        flash[:notice] = "Login or create an account to add the product to your gift registry"
      end
      redirect_to account_select_registry_path and return
      
    else
      redirect_to cart_path and return
    end
    
  end #end method add
  
  
  def add_wish_list_item
    find_cart
    wl_item = WishListItem.find(params[:wish_list_item_id])
    @cart.add(wl_item.to_cart_item_params)
    redirect_to cart_path and return
  end #end method add_wish_list_item

  
  
  
  #remove item from cart
  def remove
    find_cart
    item = @cart.cart_items.find(params[:cart_item_id])
    if item
      item.destroy
    end
    redirect_to cart_path
  end #end method remove
  
  
  #update cart item qty
  def update
    find_cart
    item = @cart.cart_items.find(params[:cart_item_id])
    if item
      item.update_attributes(:quantity => params[:qty])
    end
    redirect_to cart_path
  end #end method update
  
  
  #add a coupon to cart
  def add_coupon
    @page_title = "Add Coupon"
    find_cart
    @coupon = Coupon.find_by_coupon_number(params[:coupon_number])
    
    unless @coupon
      @coupon_error = "Not found"
      render :action => 'index' and return
    end
    
    if @coupon.used == true && @coupon.reusable == false
      @coupon_error = "Already used"
      render :action => 'index' and return
    end
    
    @cart.coupon = @coupon
    @cart.save
    redirect_to cart_path
    
  end #end method add_coupon
  
  
  def login
    
    if logged_in?
      find_cart
      @cart.load_user_data(current_user)
      redirect_to cart_billing_shipping_path and return
    end
    
    @page_title = "Login"
    @user = User.new
  end #end method login
  
  
  def submit_login
    @page_title = "Login"
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
      
      find_cart
      @cart.load_user_data(current_user)
      
      if user.has_role?("admin")
        redirect_back_or_default(admin_products_path)
      else
        redirect_back_or_default(cart_billing_shipping_path)
      end
      
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @email       = params[:login][:email]
      @remember_me = params[:login][:remember]
      render :action => 'login'
    end
  end #end method submit_login
  
  
  def user_signup
    @page_title = "Login"
    @user = User.new(params[:user])
    @user.role_ids = [1]
    
    if @user.save
      logout_keeping_session!
      self.current_user = @user
      
      find_cart
      @cart.load_user_data(current_user)
      
      flash[:notice] = "Thanks for signing up!"
      redirect_back_or_default(cart_billing_shipping_path)
    else
      render :action => 'login'
    end
    
  end #end method user_signup
  
  
  
  def billing_shipping
    @page_title = "Order Billing and Shipping"
    find_cart
    if @cart.items.empty?
      flash[:error] = "Your cart is empty"
      redirect_to cart_path
    end
    
    
    if @cart.billing_address.blank? && logged_in?
      @cart.user_profile_type_id = current_user.user_profile_type_id
      @cart.billing_first_name   = current_user.billing_first_name
      @cart.billing_last_name    = current_user.billing_last_name 
      @cart.billing_address      = current_user.billing_address   
      @cart.billing_address2     = current_user.billing_address2  
      @cart.billing_city         = current_user.billing_city      
      @cart.billing_state_id     = current_user.billing_state_id  
      @cart.billing_zipcode      = current_user.billing_zipcode   
      @cart.billing_country_id   = current_user.billing_country_id
    end #end billing address
    
    
    if @cart.shipping_address.blank? && logged_in?
      
      @cart.shipping_first_name  = current_user.shipping_first_name
      @cart.shipping_last_name   = current_user.shipping_last_name 
      @cart.shipping_address     = current_user.shipping_address   
      @cart.shipping_address2    = current_user.shipping_address2  
      @cart.shipping_city        = current_user.shipping_city      
      @cart.shipping_state_id    = current_user.shipping_state_id  
      @cart.shipping_zipcode     = current_user.shipping_zipcode   
      @cart.shipping_country_id  = current_user.shipping_country_id
      @cart.shipping_phone       = current_user.shipping_phone  
      
      if current_user.user_profile_type_id == Order::ADDRESS_DORM
        @cart.dorm_ship_college_name  = current_user.dorm_ship_college_name
        @cart.dorm_ship_not_assigned  = current_user.dorm_ship_not_assigned
        @cart.dorm_ship_not_part      = current_user.dorm_ship_not_part    
      end #end if dorm        
         
    end #end shipping_address
    
    
  end #end method billing_shipping
  
  
  def save_billing_shipping
    @page_title = "Order Billing and Shipping"
    unless request.post? || request.put?
      redirect_to cart_billing_shipping_path
    end
    
    
    find_cart
    saved = @cart.update_attributes(params[:cart])
    
    if @cart.should_validate? && saved
      redirect_to cart_review_path
    else
      render :action => 'billing_shipping'
    end
    
  end #end method save_billing_shipping
  
  
  
  def review
    @page_title = "Review Order"
    find_cart
    if @cart.items.empty?
      flash[:error] = "Your cart is empty"
      redirect_to cart_path and return
    end
    
    @cart.should_validate = 1
    unless @cart.valid?
      flash[:error] = "Please complete the billing / shipping section"
      redirect_to cart_billing_shipping_path and return
    end
    
  end #end method review
  
  
  
  def confirm
    @page_title = "Order Confirmation"
    find_cart
    if @cart.items.empty?
      flash[:error] = "Your cart is empty"
      redirect_to cart_path and return
    end
    
    @order = Order.new_from_cart(@cart)
    @order.client_ip_address = request.remote_ip
    
    if @order.save
      
      #save the order into their session
      session[:order_id] = @order.id
      
      #destroy cart
      @cart.destroy
      session[:cart_id] = nil
      
    else
      @order.errors.full_messages.each do |msg|
        @cart.errors.add_to_base(msg)
      end
      render :action => "billing_shipping"
    end
    
  end #end method confirm
  
  
  
  def print

    if session[:order_id].blank?
      flash[:error] = "Order not found"
      redirect_to root_path
    end
    
    @order = Order.find(session[:order_id])
    render :partial => "shared/packing_list.html.erb", :layout => "packing_list"
    
  end #end method print
  

end
