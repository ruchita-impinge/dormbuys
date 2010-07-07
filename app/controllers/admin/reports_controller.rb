class Admin::ReportsController < Admin::AdminController
  
  
  def inventory_count_list
    
    @file_name = "inventory_count_inv_products_only"
    @variations = ProductVariation.find(:all, :include => [:product])
    @variations.reject!{|x| x if x.product.blank?}
    @variations.reject! {|x| x.product.drop_ship}
    
    @variations.sort! {|x,y| x.full_title <=> y.full_title}
    
    #variation.product.subcategories.first.name
    #variation.product.subcategories.first.category.name
    
    headers['Content-Type'] = "application/vnd.ms-excel" 
    headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xls\""
    headers['Cache-Control'] = ''
    
    render :layout => false
    
  end #end method inventory_count_list
  
  
  
  def email_list
    @emails = EmailListClient.find(:all).collect(&:email) | DormBucksEmailListClient.find(:all).collect(&:email)
    @users = User.find(:all)
    
    @output = []
    
    @emails.each {|mail| @output << ["","",mail] }
    @users.each {|u| @output << [u.first_name, u.last_name, u.email] }
    
		headers['Content-Type'] = "application/vnd.ms-excel" 
    headers['Content-Disposition'] = 'attachment; filename="email-list-export.xls"'
    headers['Cache-Control'] = ''
    
    render :layout => false
  end #end method email_list
  
  
  
  def coupons_used
    
    if request.post? || request.put?
      @from_date = Time.parse(params[:from_date])
      @to_date   = Time.parse(params[:to_date])
      @selected_coupon = params[:coupon].blank? ? nil : params[:coupon].to_i
    else  
      @from_date = Time.parse("#{Time.now.month}/1/#{Time.now.year}")
      @to_date   = Time.now
      @selected_coupon = nil
    end #end if request.post?
    
    
    # get a list of orders
    conditions = []
    conditions << ["order_date >= ?", @from_date]
    conditions << ["order_date <= ?", @to_date]
    conditions << ["order_status_id != ?", Order::ORDER_STATUS_CANCELED]
    conditions << ["coupon_id != ?", "NULL"] unless @selected_coupon
    conditions << ["coupon_id = ?", @selected_coupon] if @selected_coupon    
    
    @orders = Order.find(:all, 
      :conditions => [conditions.transpose.first.join(' AND '), *conditions.transpose.last],
      :order => 'order_date DESC, coupon_id ASC')
      
    # build the ddl of coupons, we want the DDL to only have coupon numbers
    # for the date range, but to keep the whole list, if we drill down into one,
    # so that we can drill down into another
    @coupons = [["",""]]
    @coupon_orders = Order.find(:all, 
      :conditions => ["order_date >= ? AND order_date <= ? AND order_status_id != ? AND coupon_id IS NOT NULL",
        @from_date, @to_date, Order::ORDER_STATUS_CANCELED],
      :order => 'order_date DESC, coupon_id ASC')
    @coupon_orders.each {|o| @coupons << [o.coupon.coupon_number, o.coupon_id]}
    @coupons.uniq!
    @coupons.sort!{|x,y| x.first <=> y.first}
    
    @total_saved      = @orders.sum {|o| o.total_coupon}
		@total_subtotal   = @orders.sum {|o| o.subtotal}
		@total_difference = @total_subtotal - @total_saved
		@total_ten        = @total_subtotal * 0.10
		@total_eight      = @total_subtotal * 0.08
		
		if params[:export]
		  headers['Content-Type'] = "application/vnd.ms-excel" 
      headers['Content-Disposition'] = 'attachment; filename="coupons-used-export.xls"'
      headers['Cache-Control'] = ''
      render :action => :export_coupons_used_html, :layout => false
	  end
    
  end #end method coupons_used
  
  
  
end #end class