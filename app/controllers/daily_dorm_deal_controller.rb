class DailyDormDealController < ApplicationController
  
  before_filter :authenticate
  
  layout "standalone/daily_dorm_deal"
  
  def index
    @deal = DailyDormDeal.current_deal
    fresh_when(:etag => @deal, :last_modified => @deal.updated_at.utc, :public => true)
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
