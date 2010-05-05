module AdminOrderBulder
  
  def calc_shipping
    subtotal = params[:subtotal]
    shipping = ShippingRatesTable.get_rate(subtotal)
    
    render :update do |page|
      page << %($("#order_shipping").val("#{shipping.to_s}"))
      page << %(skip_shipping_calc = true; updateOrderTotals();)
    end
  end #end method calc_shipping
  
  
  
  def add_gift_card_to_order
    @gift_card = GiftCard.find_by_giftcard_number(params[:gift_card_number])
    
    errors = []
    errors << "Gift Card number was not found" unless @gift_card
    (errors << "Pin is incorrect" unless params[:gift_card_pin] == @gift_card.giftcard_pin) if @gift_card
    (errors << "Gift Card is expired" if @gift_card.expires && @gift_card.expiration_date < Date.today) if @gift_card
    (errors << "Gift Card has no money" if @gift_card.current.cents <= 0) if @gift_card
    
    render :update do |page|
      unless errors.empty?
        page << %(alert("ERRORS:\\n" + "#{errors.join("\\n")}");)
      else
          page.insert_html :bottom, "gift_cards_holder", :partial => "gift_card", :object => @gift_card
          page << "removeDuplicateGiftCards(); updateGiftCards();"
          page << %(updateOrderTotals();)
      end
    end
    
  end #end method add_gift_card_to_order
  
  
  
  def add_coupon_to_order
    
    @coupon = Coupon.find_by_coupon_number(params[:coupon_number])
    
    errors = []
    errors << "Coupon number was not found" unless @coupon
    (errors << "Coupon is expired" if @coupon.expires && @coupon.expiration_date < Date.today) if @coupon
    (errors << "Coupon was already used" if !@coupon.reusable && @coupon.used) if @coupon
    
    render :update do |page|
      unless errors.empty?
        page << %(alert("ERRORS:\\n" + "#{errors.join("\\n")}");)
      else
        page << %(jQuery("#order_coupon_id").val("#{@coupon.id}");)
        page.replace_html "coupon_holder", :partial => "coupon", :object => @coupon
        page << %(updateCoupons();)
        page << %(updateOrderTotals();)
      end
    end
    
  end #end method add_coupon_to_order
  
  
  
  def auto_complete_for_product_product_name

    product_name = params[:product_search_term]

    @products = Product.find(:all, 
      :conditions => [ "LOWER(#{params[:method]}) LIKE ?",
      '%' + product_name.downcase + '%'], 
      :order => "#{params[:method]} ASC",
      :limit => 10)

    render :partial => 'auto_complete_list', :object => @products
  end
  
  
  
  def auto_complete_for_user_email

    email = params[:user_search_term]

    @users = User.find(:all, 
      :conditions => [ "LOWER(#{params[:method]}) LIKE ?",
      email.downcase + '%'], 
      :order => "#{params[:method]} ASC",
      :limit => 10)

    render :partial => 'user_auto_complete_list', :object => @users
  end
  
  
  
  def set_user
    @user = User.find_by_email(params[:email])
    
    render :update do |page|
      if @user
        page << %($("#order_user_id").val("#{@user.id}"););
        page << %($("#order_email").val("#{params[:email]}"););
      else
        page << %(alert('user could not be found');)
      end
    end
    
  end #end method set_user
  


  def product_staging
    
    @product = Product.find_by_product_name(params[:product_name])
    
    render :update do |page|
      page.replace_html "product_staging",
        :partial => 'product_staging',
        :object => @product
      page << %(setupProductStaging();)
    end
  end #end method product_staging
  
  
  
  def insert_staged_product
    errors = []
    errors << "- quantity is required" if params[:product][:quantity].blank?
    errors << "- variation selection is required" if params[:product][:variation_id].blank?
    
    unless errors.empty?
      render :update do |page| 
        page << %(alert('ERRORS:\\n#{errors.join("\\n")}'); )
      end
      return
    end
    
    @qty = params[:product][:quantity].to_i
    variation_id = params[:product][:variation_id]
    
    if params[:product][:product_option_values]
      povs = params[:product][:product_option_values].collect {|f| f[:id].to_i }
    else
      pofs = []
    end
    
    if params[:product][:product_as_option_values]
      paovs = params[:product][:product_as_option_values].collect {|f| f[:id].to_i }
    else
      paovs = []
    end
    
    @variation = ProductVariation.find(variation_id)
    @product = @variation.product
    @product_option_values = ProductOptionValue.find(:all, :conditions => {:id => povs})
    @product_as_option_values = ProductAsOptionValue.find(:all, :conditions => {:id => paovs})
    @total_price = @variation.rounded_retail_price
    
    @product_option_values.each {|pov| @total_price += pov.price_increase }
    @product_as_option_values.each {|paov| @total_price += (paov.product_variation.rounded_retail_price + paov.price_adjustment)}
    
    render :update do |page|
      page.insert_html :bottom, "order_items", :partial => 'order_item'
      page << %($("#product_staging").html(""); $(".product_search_field").val("").focus(); updateProductTotal();)
      page << %(updateOrderTotals();)
    end
    
  end #end method insert_staged_product
  
  
  
end #end module