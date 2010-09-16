class DailyDormDealController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  
  layout "standalone/daily_dorm_deal"
  
  def index
    #@deal = DailyDormDeal.current_deal
    #unless @deal
    #  flash[:error] = "Daily Dorm Deal could not be found"
    #  redirect_to "http://dormbuys.com" and return
    #end
    #
    #set_cache_buster
    
    # => See application_controller.check_standalone
    
  end
  
  
  def email_signup
=begin  --> Depreciated 9/14/2010

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
=end

    unless params && params[:ddd_email_signup] && params[:ddd_email_signup][:email] && !params[:ddd_email_signup][:email].blank?
      email = ""
    else
      email = params[:ddd_email_signup][:email]
    end #end unless


    redirect_to "/deal_signup?email=" + email

  end #end method email_signup
  
  
  
  def deal_signup
    @email = params[:email] ? params[:email] : ""
  end #end method signup
  
  
  def deal_signup_save
    render :update do |page|
      if params[:ddd_deal_signup].blank? ||
        params[:ddd_deal_signup][:first_name].blank? ||
        params[:ddd_deal_signup][:last_name].blank? ||
        params[:ddd_deal_signup][:email].blank? ||
        params[:ddd_deal_signup][:who_are_you].blank?
        
        page.alert "Error: All fields are required"
        
      else
        begin
          ifs = Infusionsoft.new
          id = ifs.find_or_create(params[:ddd_deal_signup][:first_name], params[:ddd_deal_signup][:last_name], params[:ddd_deal_signup][:email])
          ifs.api_add_to_group(id, ifs.get_who_am_i_constant_prospect(params[:ddd_deal_signup][:who_are_you]))
          ifs.api_add_to_group(id, Infusionsoft::TAG_DAILY_DEAL)
          page << "window.location.href = 'http://dailydormdeal.com?signup_thanks=1';"
        rescue => e
          HoptoadNotifier.notify(
            :error_class => "D3 Deal Signup",
            :error_message => "!!! - D3 Deal Signup: #{e.message}"
          )
          page.alert "Oops: Something went wrong, we couldn't sign you up. :-("
        end
      end
    end #end render
  end #end method signup_save
  

end #end class