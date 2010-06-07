class Admin::AdminController < ApplicationController

  include RoleRequirementSystem
  
  before_filter :login_required
  require_role("admin")
  
  def ssl_required?
    true
  end #end method ssl_required?
  
end #end class