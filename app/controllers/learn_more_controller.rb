class LearnMoreController < ApplicationController
  
  ssl_allowed :not_assigned, :secure_shopping, :ship_date, :vcode, :check_giftcard, :check_gc_balance
  
  layout "lightwindow"
  
  def not_assigned
  end
  
  def secure_shopping
  end
  
  def ship_date
  end
  
  def vcode
  end
  
  def check_giftcard
  end
  
  def check_gc_balance
    @gift_card = GiftCard.find(:first, :conditions => {:giftcard_number => params[:gift_card], :giftcard_pin => params[:pin]})
  
    render :update do |page|
      
      if @gift_card
        
        output = %(<span class="success">)
        output << %(Current Balance: #{@gift_card.current_amount})
        output << %(&nbsp;&nbsp;&nbsp;&nbsp;)
      
        if @gift_card.expires
          output << %(Expiration Date: #{@gift_card.expiration_date.strftime("%m/%d/%Y")}) 
        else
          output << %(Card does not expire.)
        end
        page.replace_html "gc_info", output
        #page.visual_effect :highlight, 'gc_info', {:duration => 2.0}
      else
        output = %(<span class="error">Gift Card was not found</span>)
        page.replace_html "gc_info", output
        #page.visual_effect :highlight, 'gc_info', {:duration => 2.0}
      end
      
    end #end render
  
  end #end method check_gc_balance
  
  
end
