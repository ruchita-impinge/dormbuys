class CartController < ApplicationController
  
  #protect_from_forgery :except => :add
  skip_before_filter :verify_authenticity_token
  
  
  ssl_required :login, :submit_login, :user_signup, :billing_shipping, 
    :save_billing_shipping, :review, :confirm
  
  layout "front_short_banner"
  
  #view cart
  def index
    @page_title = "View Cart"
    find_cart
    
    #hack to auto-apply a coupon
    # if Time.now >= Time.parse("06/30/2010 9:00 AM")
    #   @coupon = Coupon.find_by_coupon_number "ship4free"
    #   if @cart.coupon.blank?
    #     @cart.coupon = @coupon 
    #     @cart.save
    #   end
    # end
    
  end
  
  
  #add item to cart
  def add
    
    if params[:cart_item].blank?
      flash[:error] = "Error adding to cart, try again or call 1-866-502-DORM for help"
      redirect_to request.referrer and return
    end
    
    if params[:cart_item][:variation_id].blank?
      flash[:error] = "Use the first drop down list to select the product variation"
      redirect_to request.referrer and return
    end
    

    #DAILY DEAL VALIDATION
    if request.referrer =~ /dailydeal/ || request.referrer =~ /dailydormdeal/
      if params[:cart_item][:product_option_values].blank? || params[:cart_item][:product_option_values].first[:id].blank?
        flash[:error] = "Please select a value for all drop down lists"
        redirect_to request.referrer and return
      end
    end
    
    #wrap-up-america VALIDATION
    if request.referrer =~ /wrapup/ || request.referrer =~ /wrapup/
      if params[:cart_item][:product_option_values].blank? || params[:cart_item][:product_option_values].first[:id].blank?
        flash[:error] = "Please select a value for all drop down lists"
        redirect_to request.referrer and return
      end
    end
    

    if params[:cart_item][:qty].blank?
      flash[:error] = "You must specify a quantity"
      redirect_to request.referrer and return
    end
    
    find_cart
    
    cart_add_result = @cart.add(params[:cart_item])
    
    
    if cart_add_result.first == false
      flash[:error] = cart_add_result.last
      redirect_to request.referrer and return
    end
    
    
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
    
    
    #final fail safe
    redirect_to cart_path and return
    
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
    
    if @cart.subtotal < @coupon.min_purchase
      @coupon_error = "#{@coupon.min_purchase} minimum required"
      render :action => 'index' and return
    end
    
    if @coupon.is_expired?
      @coupon_error = "Coupon is expired"
      render :action => 'index' and return
    end
    
    if @cart.coupon
      flash[:notice] = "Only 1 coupon per order.  Coupon: #{@coupon.coupon_number} added, Coupon: #{@cart.coupon.coupon_number} removed"
      @cart.coupon = @coupon
    else
      @cart.coupon = @coupon
    end
    
    
    @cart.save
    redirect_to cart_path
    
  end #end method add_coupon
  
  
  def login
    @cart_step = "login"
    
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
    login = params[:login][:email] rescue ""
    pass = params[:login][:password] rescue ""
    remember = params[:login][:remember] rescue ""
    user = User.authenticate(login, pass)
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (remember == "1")
      handle_remember_cookie! new_cookie_flag
      
      find_cart
      @cart.load_user_data(current_user)
      
      #if user.has_role?("admin")
      #  redirect_back_or_default(admin_products_path)
      #else
      #  redirect_back_or_default(cart_billing_shipping_path)
      #end
      redirect_back_or_default(cart_billing_shipping_path)
      
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @email       = login
      @remember_me = pass
      redirect_to cart_login_path
    end
  end #end method submit_login
  
  
  def user_signup
    @cart_step = "login"
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
    @cart_step = "billing_shipping"
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
    
    
    #handle shipping gift_registry
    gr = @cart.gift_registry
    if @cart.shipping_address.blank? && gr
      @cart.shipping_first_name  = gr.user.first_name
      @cart.shipping_last_name   = gr.user.last_name
      @cart.shipping_address     = gr.shipping_address   
      @cart.shipping_address2    = gr.shipping_address2  
      @cart.shipping_city        = gr.shipping_city      
      @cart.shipping_state_id    = gr.shipping_state_id  
      @cart.shipping_zipcode     = gr.shipping_zip_code   
      @cart.shipping_country_id  = gr.shipping_country_id
      @cart.shipping_phone       = gr.shipping_phone
    end #end gift_registry_address
    

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
          
            
    @cart_step = "billing_shipping"
    @page_title = "Order Billing and Shipping"
    
    unless request.post? || request.put?
      redirect_to cart_billing_shipping_path and return
    end
    
    
    find_cart
    
    
    begin
      @cart.attributes = params[:cart]
      @cart.dorm_shipping_address2 = params[:cart][:dorm_shipping_address2] unless params[:cart][:dorm_shipping_address2].blank?
      saved = @cart.save
    rescue => e
      @cart.errors.add_to_base(e.message)
      render :action => 'billing_shipping'and return
    end
    
    
    if @cart.should_validate? && saved
 
      
      #if update the user's profile
      if params[:update_profile].to_i == 1 && !current_user.blank?
        
        current_user.user_profile_type_id   = @cart.user_profile_type_id
        current_user.billing_first_name     = @cart.billing_first_name
        current_user.billing_last_name      = @cart.billing_last_name
        current_user.billing_address        = @cart.billing_address
        current_user.billing_address2       = @cart.billing_address2    
        current_user.billing_city           = @cart.billing_city
        current_user.billing_state_id       = @cart.billing_state_id    
        current_user.billing_zipcode        = @cart.billing_zipcode      
        current_user.billing_country_id     = @cart.billing_country_id
        current_user.shipping_first_name    = @cart.shipping_first_name  
        current_user.shipping_last_name     = @cart.shipping_last_name  
        current_user.shipping_address       = @cart.shipping_address  
        current_user.shipping_address2      = @cart.shipping_address2    
        current_user.shipping_city          = @cart.shipping_city     
        current_user.shipping_state_id      = @cart.shipping_state_id
        current_user.shipping_zipcode       = @cart.shipping_zipcode    
        current_user.shipping_country_id    = @cart.shipping_country_id
        current_user.shipping_phone         = @cart.shipping_phone         
        current_user.dorm_ship_college_name = @cart.dorm_ship_college_name
        current_user.dorm_ship_not_assigned = @cart.dorm_ship_not_assigned
        current_user.dorm_ship_not_part     = @cart.dorm_ship_not_part 
        current_user.billing_phone          = @cart.billing_phone      
        current_user.whoami                 = @cart.whoami
        
        current_user.save(false)       
        
      end #end profile update
      
      redirect_to cart_review_path and return
    else
      render :action => 'billing_shipping' and return
    end
    
  end #end method save_billing_shipping
  
  
  
  def review
    @cart_step = "review"
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
    @cart_step = "confirm"
    @page_title = "Order Confirmation"
    find_cart
    if @cart.items.empty?
      flash[:error] = "Your cart is empty"
      redirect_to cart_path and return
    end
    
    
    begin
      @order = Order.new_from_cart(@cart)
      @order.client_ip_address = request.remote_ip
    rescue => e
      @cart.errors.add_to_base(e.message)
      render :action => "billing_shipping" and return
    end
    
    
    if @order.save
      
      #save the order into their session
      session[:order_id] = @order.id
      
      #destroy cart
      @cart.finalize_wrap_up_america_sales
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
