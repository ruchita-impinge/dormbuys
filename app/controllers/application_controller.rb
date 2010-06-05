# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem

  before_filter :set_current_user


  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  
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
  
  
end
