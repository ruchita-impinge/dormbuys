# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  include AuthenticatedSystem  
  
  BETA_USER_ID = "dormbuys"
  BETA_PASSWORD = "whodat"

  #before_filter :authenticate_for_beta
  before_filter :check_domain, :set_current_user


  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :vcode, :card_number,
    #:name_on_card, :exp_date, :card_type
  
  
  def check_domain
    if request.domain.downcase == "www.dormbuys.com"
      redirect_to "http://dormbuys.com"
    end
  end #end method check_domain
  
  
  def set_current_user
    User.current_user = self.current_user
  end #end method set_current_user
  
  
  def find_cart
    return @cart unless @cart.blank?
  
  
    if session[:cart_id]
      begin
        @cart = Cart.find(session[:cart_id])
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
    flash[:error] = "Couldn't log you in as '#{params[:login][:email]}'"
    logger.warn "Failed login for '#{params[:login][:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  
  
  def expire_general_caches
    %w(home_page_1 home_page_2 front_large_banner_1 front_large_banner_2 front_large_banner_3 front_short_banner_1 front_short_banner_2).each do |frag|
      if fragment_exist? frag
	      expire_fragment frag
	    end
    end
  end #end method expire_general_caches
  
  

  private
  
    #def authenticate_for_beta
    #    unless RAILS_ENV == "development"
    #      authenticate_or_request_with_http_basic do |id, password| 
    #          id == BETA_USER_ID && password == BETA_PASSWORD
    #      end
    #    end
    # end
  
  
end
