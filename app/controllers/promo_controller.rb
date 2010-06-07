class PromoController < ApplicationController
  
  
  def piemask
    render :layout => false
  end

  def dormbucks
    render :layout => false
  end
  
  def check_dorm_bucks
    
    email_list_client = DormBucksEmailListClient.find_by_email(params[:email])
    unless email_list_client
      
      new_email_list_client = DormBucksEmailListClient.new(:email => params[:email])
      unless new_email_list_client.save
        errors = new_email_list_client.errors.full_messages.join("; ")
        render :text => "Error: #{errors}"
        return
      end
      
    end
    
    @coupon = Coupon.find_by_coupon_number(params[:code])
    
    unless @coupon
      render :text => "Error: Code couldn't be found"
      return
    end
    

    type = nil
    amount = nil
    
    if @coupon.coupon_type_id == 1 #fixed dollar discount
      type = "dollar"
      amount = "#{@coupon.value.to_s}"
    elsif @coupon.coupon_type_id == 2 #percentage
      type = "percentage"
      amount =  "#{@coupon.value}% Off"
    end
    
    if type == nil || amount == nil
      render :text => "Error: please contact Dormbuys.com at 1-866-502-DORM for more assistance."
      return
    end
    
    
    render :text => "#{type}-#{amount}"
    
  end #end method check_dorm_bucks

end
