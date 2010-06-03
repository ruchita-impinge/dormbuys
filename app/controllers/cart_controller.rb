class CartController < ApplicationController
  
  layout "front_short_banner"
  
  #view cart
  def index
    find_cart
  end
  
  
  #add item to cart
  def add
    find_cart
    @cart.add(params[:cart_item])
    redirect_to cart_path
  end #end method add
  
  
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
    @user = User.new
  end #end method login
  
  
  def submit_login
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
    @user = User.new(params[:user])
    @user.role_ids = [1]
    
    if @user.save
      logout_keeping_session!
      self.current_user = @user
      
      flash[:notice] = "Thanks for signing up!"
      redirect_to cart_billing_shipping_path
    else
      render :action => 'login'
    end
    
  end #end method user_signup
  
  
  
  def billing_shipping
    find_cart
    if @cart.cart_items.empty?
      flash[:error] = "Your cart is empty"
      redirect_to cart_path
    end
  end #end method billing_shipping
  
  
  def save_billing_shipping
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
    find_cart
    if @cart.cart_items.empty?
      flash[:error] = "Your cart is empty"
      redirect_to cart_path
    end
  end #end method review
  
  
  
  def confirm
    find_cart
    if @cart.cart_items.empty?
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
  
  
  
  protected
  
    # Track failed login attempts
    def note_failed_signin
      flash[:error] = "Couldn't log you in as '#{params[:login][:email]}'"
      logger.warn "Failed login for '#{params[:login][:email]}' from #{request.remote_ip} at #{Time.now.utc}"
    end

  private
  
    def find_cart
      return @cart unless @cart.blank?
    
    
      if session[:cart_id]
        @cart = Cart.find(session[:cart_id])
      elsif logged_in?
      
        if current_user.carts.first
          @cart = current_user.carts.first
        else
          @cart = current_user.carts.create
        end
      
      else
        @cart = Cart.create
      end
    
      session[:cart_id] = @cart.id
      return @cart
    
    end #end method find_cart

end
