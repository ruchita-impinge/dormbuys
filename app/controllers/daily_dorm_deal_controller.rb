class DailyDormDealController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  #before_filter :authenticate  
  
  layout "standalone/daily_dorm_deal"
  
  def index
    @deal = DailyDormDeal.current_deal
    unless @deal
      flash[:error] = "Daily Dorm Deal could not be found"
      redirect_to "http://dormbuys.com" and return
    end
    
    set_cache_buster
  end
  
  def email_signup
    render :update do |page|
      unless params && params[:ddd_email_signup] && params[:ddd_email_signup][:email] && !params[:ddd_email_signup][:email].blank?
        page.alert "Email is required"
      else
        sub = DailyDormDealEmailSubscriber.new(params[:ddd_email_signup])
        if sub.save
          page.alert "Thanks for signing up!"
          page << "$('#email').val('');"
        else
          msgs = sub.errors.full_messages.join('\n')
          page << "alert(\"Errors:\\n#{msgs}\")"
        end
      end #end unless
    end #end render
  end #end method email_signup


private

  def authenticate
    authenticate_or_request_with_http_basic do |id, password| 
        id == "dormbuys" && password == "whodat"
    end
  end


end
