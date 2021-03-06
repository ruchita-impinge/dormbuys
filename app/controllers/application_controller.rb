# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  include AuthenticatedSystem  
  

  rescue_from ActionController::RoutingError, :with => :route_not_found
  rescue_from ActionController::MethodNotAllowed, :with => :invalid_method
  rescue_from ActionController::UnknownHttpMethod, :with => :route_not_found
  rescue_from REXML::ParseException, :with => :bad_xml
  rescue_from 'REXML::ParseException' do |exception|
    render :text => 'Your XML is malformed', :status => :unprocessable_entity
  end
  
  

  before_filter :set_current_user, :check_standalone, :set_site_banner


  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :vcode, :card_number,
    #:name_on_card, :exp_date, :card_type
  
  
  def set_site_banner
    
    if params[:confirm_site_banner].to_i == 1
      if sb = SiteBanner.active.first
        session[:confirm_site_banner] = sb.id
      end
    end
      
      
    unless self.class.to_s =~ /Admin/
      
      if sb = SiteBanner.active.first
        
        banner = "<b>#{sb.title}</b><br /><br />#{sb.message}"
        
        if sb.confirmation_required? && !site_banner_confirmed?
          banner += %(<br /><br /><input type='button' value='OK' onclick='window.location.href="?confirm_site_banner=1"' />)
        end
        
        return if site_banner_confirmed? # && allow_purchase?
        
        flash[:site_banner] = banner
        flash.discard
        
      end #end if sb
      
    end #end unless
  end #end method set_site_banner
  
  
  def site_banner_confirmed?
    if sb = SiteBanner.active.first
      return session[:confirm_site_banner].to_i == sb.id
    end
    return false
  end #end method site_banner_confirmed?
  
  
  def set_current_user
    User.current_user = self.current_user
  end #end method set_current_user
  
  
  def check_standalone
    if "#{request.domain}".downcase == "dailydormdeal.com"
      
      if request.path =~ /email_signup/ || request.path =~ /deal_signup/
        return true
      else
        @deal = DailyDormDeal.current_deal
      
        unless @deal
          flash[:error] = "Daily Dorm Deal could not be found"
          redirect_to "http://dormbuys.com" and return true
        end
      
        set_cache_buster
      
        render :file => "daily_dorm_deal/index.html.erb", :layout => "standalone/daily_dorm_deal" and return true
        
      end
    end
    
    return true
  end #end method check_standalone
  
  
  def set_cache_buster
    headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    headers["Pragma"] = "no-cache"
    headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
  
  
  
  def recent_product_ids
    session[:recent_product_ids] || []
  end #end method recent_product_ids
  
  
  def log_product_viewed(product)
    if session[:recent_product_ids].blank?
      session[:recent_product_ids] = [product.id]
    else
      session[:recent_product_ids] << product.id
    end
    session[:recent_product_ids].uniq!
    
    if session[:recent_product_ids].length > 10
      session[:recent_product_ids] = session[:recent_product_ids][session[:recent_product_ids].length - 10, session[:recent_product_ids].length]
    end
    
  end #end method log_product_viewed(product)
  
  
  def find_cart
    return @cart unless @cart.blank?
  
  
    if session[:cart_id]
      begin
        @cart = Cart.find(session[:cart_id])
        if @cart && logged_in?
          if @cart.user.blank?
            @cart.user = current_user
            @cart.save
          end
        end
      rescue
        @cart = Cart.create
      end
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
  
  
  # Track failed login attempts
  def note_failed_signin
    login = params[:login][:email] rescue "blank"
    flash[:error] = "Couldn't log you in as '#{login}'"
    logger.warn "Failed login for '#{login}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  
  
  def expire_general_caches
    %w(home_page_1 home_page_2 home_page_3 home_page_featured-0 home_page_featured-1 home_page_featured-2 front_large_banner_0 front_large_banner_1 front_large_banner_2 front_large_banner_3 front_short_banner_1 front_short_banner_2).each do |frag|
      if fragment_exist? frag
	      expire_fragment frag
	    end
    end
  end #end method expire_general_caches
  
  
  def expire_home_caches
    %w(home_page_1 home_page_2 home_page_3 home_page_featured-0 home_page_featured-1 home_page_featured-2).each do |frag|
      if fragment_exist? frag
        expire_fragment frag
      end
    end
  end #end method expire_home_caches
  
  
  def expire_home_banner_caches
    %w(home_page_2).each do |frag|
      if fragment_exist? frag
        expire_fragment frag
      end
    end
  end #end method expire_home_banner_caches
  
  
  private

  def route_not_found
    render :text => "Hmmm... what are you looking for?  I couldn't find anything with that URL.", :status => :not_found
  end


  def invalid_method
    message = "#{request.request_method.to_s.upcase} is not allowed"
    render :text => message, :status => :method_not_allowed
  end


  def bad_xml
    render :text => 'Your XML is malformed', :status => :unprocessable_entity
  end #end method bad_xml

  
end #end  class
