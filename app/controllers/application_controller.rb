# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  include AuthenticatedSystem  
  
  BETA_USER_ID = "dormbuys"
  BETA_PASSWORD = "whodat"

  before_filter :authenticate_for_beta
  before_filter :set_current_user


  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :vcode, :card_number,
    #:name_on_card, :exp_date, :card_type
  
  
  def set_current_user
    User.current_user = self.current_user
  end #end method set_current_user
  
  
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
  
  
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login][:email]}'"
    logger.warn "Failed login for '#{params[:login][:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  private
  
    def authenticate_for_beta
        unless RAILS_ENV == "development"
          authenticate_or_request_with_http_basic do |id, password| 
              id == BETA_USER_ID && password == BETA_PASSWORD
          end
        end
     end
  
  
end
