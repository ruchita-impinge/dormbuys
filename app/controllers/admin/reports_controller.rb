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
  
  
  def daily_dorm_deal_email_list
    @emails = DailyDormDealEmailSubscriber.find(:all).collect(&:email)
    
    @output = "Emails\n"
    
    @emails.each {|e| @output += "#{e}\n" }
    
		headers['Content-Type'] = "application/csv" 
    headers['Content-Disposition'] = 'attachment; filename="daily-dorm-deal.csv"'
    headers['Cache-Control'] = ''
    
    render :text => @output
  end #end method daily_dorm_deal_email_list
  
  
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
      
    @orders.reject! {|o| o if o.coupon.blank? }
    
    # build the ddl of coupons, we want the DDL to only have coupon numbers
    # for the date range, but to keep the whole list, if we drill down into one,
    # so that we can drill down into another
    @coupons = [["",""]]
    @coupon_orders = Order.find(:all, 
      :conditions => ["order_date >= ? AND order_date <= ? AND order_status_id != ? AND coupon_id IS NOT NULL",
        @from_date, @to_date, Order::ORDER_STATUS_CANCELED],
      :order => 'order_date DESC, coupon_id ASC')
      
    @coupon_orders.reject! {|o| o if o.coupon.blank? }
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
  
  
  def late_shippers
    
    if request.post? || request.put?
      @from_date = Time.parse(params[:from_date])
      @to_date   = Time.parse(params[:to_date])
    else  
      @from_date = 6.days.ago
      @to_date   = Time.now
    end #end if request.post?
    
    @orders = Order.find(:all, 
      :conditions => ['order_date >= ? AND order_date <= ? AND (order_status_id = ? OR order_status_id = ?)',
        @from_date, @to_date, Order::ORDER_STATUS_WAITING, Order::ORDER_STATUS_PARTIAL],
      :order => 'order_date DESC')
    
  end #end method late_shippers
  
   
  def cogs
    
    if request.post? || request.put?
      
      @from_date = Time.parse(params[:from_date])
      @to_date   = Time.parse(params[:to_date])
      
      orders = Order.find(:all, 
        :conditions => [
          'order_date >= ? AND order_date <= ? AND (order_status_id != ?)', 
          @from_date, 
          @to_date, 
          Order::ORDER_STATUS_CANCELED
        ], 
        :include => [:order_line_items],
        :order => 'order_date DESC')
      
      @output = []
      
      line_items = orders.collect {|o| o.order_line_items }.flatten
      
      line_items.group_by(&:product_number).each do |pnum, items|
        
        variation = ProductVariation.find_by_product_number(pnum)
        if variation
          
          begin
            data = {}
            data[:qty] = items.collect {|x| x.quantity }.sum
            data[:name] = items.first.item_name
            data[:wholesale_price] = variation.wholesale_price
            data[:freight_in_price] = variation.freight_in_price
            data[:cogs_unit] = data[:wholesale_price] + data[:freight_in_price]
            data[:unit_price] = variation.rounded_retail_price
            data[:cogs_total] = data[:cogs_unit] * data[:qty]
            data[:total_sales] = data[:unit_price] * data[:qty].to_i
        
            ts = data[:total_sales].cents / 100.0
            tc = data[:cogs_total].cents / 100.0
            if ts > 0
              data[:margin] = (((ts-tc) / ts) * 100).round(2)
            else
              data[:margin] = 0.00
            end
          rescue
            raise data.collect {|elm| "#{elm.first} = #{elm.last}" }.join(", ")
          end
        
          @output << data
          
        end #end if
        
      end #end each
      
      #sort by quantity
      @output.sort!{|x,y| y[:qty] <=> x[:qty]}
      
      #calc totals
      @t_wholesale    = @output.collect {|x| x[:wholesale_price] * x[:qty]}.sum.to_s.to_f
      @t_freight_in   = @output.collect {|x| x[:freight_in_price] * x[:qty]}.sum.to_s.to_f
      @t_cogs         = @output.collect {|x| x[:cogs_total]}.sum.to_s.to_f
      @t_sales        = @output.collect {|x| x[:total_sales]}.sum.to_s.to_f
      @t_discounts    = orders.collect {|o| o.total_coupon }.sum.to_s.to_f
      @t_gross_margin = @t_sales > 0 ? (((@t_sales-@t_cogs) / @t_sales) * 100).round(2) : 0
      @t_net_margin   = @t_sales > 0 ? (((@t_sales-@t_discounts-@t_cogs) / @t_sales) * 100).round(2) : 0

    else
      @from_date = Time.now.beginning_of_month
      @to_date   = Time.now
      @output = []
    end
    
  end #end method cogs
  
  
  def inventory_cost
    @variations = ProductVariation.all(
      :conditions => ["qty_on_hand > 0"], 
      :order => "qty_on_hand DESC",
      :include => [:product])
      
    @variations.reject!{|v| v if v.product.blank? }
    @variations.reject!{|v| v if v.product.drop_ship }
    
    @t_wholesale    = @variations.collect {|x| x.wholesale_price * x.qty_on_hand }.sum
    @t_freight_in   = @variations.collect {|x| x.freight_in_price * x.qty_on_hand }.sum
    @t_cog          = (@t_wholesale + @t_freight_in).to_s.to_f
    @t_retail       = @variations.collect {|x| x.rounded_retail_price * x.qty_on_hand }.sum.to_s.to_f
    @t_margin       = (((@t_retail-@t_cog) / @t_retail) * 100).round(2)

    @file_name = "inventory_cost-#{Time.now.strftime("%Y-%m-%d")}"

    headers['Content-Type'] = "application/vnd.ms-excel" 
    headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xls\""
    headers['Cache-Control'] = ''
    
    render :layout => false

  end #end method inventory_cost
  
  
  def lnt_cogs
    if request.post? || request.put?
      
      @from_date = Time.parse(params[:from_date])
      @to_date   = Time.parse(params[:to_date])
      
      orders = Order.find(:all, 
        :conditions => [
          'order_date >= ? AND order_date <= ? AND (order_status_id != ?) AND order_vendor_id = ?', 
          @from_date, 
          @to_date, 
          Order::ORDER_STATUS_CANCELED,
          OrderVendor::LNT
        ], 
        :include => [:order_line_items],
        :order => 'order_date DESC')
      
      @output = []
      
      line_items = orders.collect {|o| o.order_line_items }.flatten
      
      line_items.group_by(&:product_number).each do |pnum, items|
        
        variation = ProductVariation.find_by_product_number(pnum)
        if variation
          
          begin
            data = {}
            data[:qty] = items.collect {|x| x.quantity }.sum
            data[:name] = items.first.item_name
            data[:wholesale_price] = variation.wholesale_price
            data[:freight_in_price] = variation.freight_in_price
            data[:cogs_unit] = data[:wholesale_price] + data[:freight_in_price]
            data[:unit_price] = variation.rounded_retail_price
            data[:cogs_total] = data[:cogs_unit] * data[:qty]
            data[:total_sales] = data[:unit_price] * data[:qty].to_i
        
            ts = data[:total_sales].cents / 100.0
            tc = data[:cogs_total].cents / 100.0
            if ts > 0
              data[:margin] = (((ts-tc) / ts) * 100).round(2)
            else
              data[:margin] = 0.00
            end
          rescue
            raise data.collect {|elm| "#{elm.first} = #{elm.last}" }.join(", ")
          end
        
          @output << data
          
        end #end if
        
      end #end each
      
      #sort by quantity
      @output.sort!{|x,y| y[:qty] <=> x[:qty]}
      
      #calc totals
      @t_wholesale    = @output.collect {|x| x[:wholesale_price] * x[:qty]}.sum.to_s.to_f
      @t_freight_in   = @output.collect {|x| x[:freight_in_price] * x[:qty]}.sum.to_s.to_f
      @t_cogs         = @output.collect {|x| x[:cogs_total]}.sum.to_s.to_f
      @t_sales        = @output.collect {|x| x[:total_sales]}.sum.to_s.to_f
      @t_discounts    = orders.collect {|o| o.total_coupon }.sum.to_s.to_f
      @t_gross_margin = @t_sales > 0 ? (((@t_sales-@t_cogs) / @t_sales) * 100).round(2) : 0
      @t_net_margin   = @t_sales > 0 ? (((@t_sales-@t_discounts-@t_cogs) / @t_sales) * 100).round(2) : 0

    else
      @from_date = Time.now.beginning_of_month
      @to_date   = Time.now
      @output = []
    end
  end #end method lnt_cogs
  
  
  def not_visible
    @products = Product.find(:all,
      :conditions => {:visible => false},
      :order => 'product_name ASC').paginate :page => params[:page], :per_page => 10
  end #end method not_visible
  
  
  def products_sold

    if request.post? || request.put?
      
      @from_date = Time.parse(params[:from_date])
      @to_date   = Time.parse(params[:to_date])
      @file_name = "products_sold_#{params[:from_date].gsub("/", "")}_to_#{params[:to_date].gsub("/", "")}"

      @line_items = [] # <= array of hashes
      
      # product_full_title, qty_sold,  mf_number, price
      # item_name, qty_sold, mf_num, price
      
      orders = Order.find(:all, 
        :conditions => [
          'order_date >= ? AND order_date <= ? AND order_status_id != ?',
          @from_date, @to_date, Order::ORDER_STATUS_CANCELED
        ],
        :include => [:order_line_items]
      )
      
      order_items = [] #temp array for sorting
      orders.each do |o|
        o.order_line_items.each do |oli|
          if params[:inv_only]
            order_items << oli unless oli.product_drop_ship
          else
            order_items << oli
          end
          
        end
      end
      
      #sort order_items by item_name alpha asc
      order_items.sort! {|x,y| x.item_name <=> y.item_name}
      
      #tmp vars
      name = "BEGIN"
      count = 0
      mf_num = ""
      price = Money.new(0)
      
      order_items.each do |oli|
        
        if name == "BEGIN"
          name = oli.item_name
          count = oli.quantity
          mf_num = oli.product_manufacturer_number
          price = oli.unit_price
        else
          
          if name == oli.item_name
            count += oli.quantity
          else
            @line_items << {
              :item_name => name,
              :qty_sold => count,
              :mf_num => mf_num,
              :price => price.to_s
            }
            name = oli.item_name
            count = oli.quantity
            mf_num = oli.product_manufacturer_number
            price = oli.unit_price
          end #end if name is the sname
          
        end #end if name == BEGIN
        
      end #end loop over order_items


      headers['Content-Type'] = "application/vnd.ms-excel" 
      headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xls\""
      headers['Cache-Control'] = ''
      
      render :partial => "products_sold_excel", :layout => false
      
    else
      @from_date = Time.parse("#{1.month.ago}")
      @to_date   = Time.now
    end #end if request.post?
    
  end #end method products_sold
  
  
  # orders with giftcards that were
  # purchased in the last week
  def gift_card_purchases
    found = Order.find(:all, :conditions => ['order_date >= ?', 1.week.ago], :order => "order_date DESC", :include => [:order_line_items])
    
    found.reject! {|o| o unless o.has_gift_card? }
    
    @orders = found.paginate :page => params[:page], :per_page => 10
  end #end method gift_card_purchases
  
  
  # shipping over total sales in a range w/ %
  def shipping_over_total
    
  if request.post? || request.put?
    @from_date = Time.parse(params[:from_date])
    @to_date   = Time.parse(params[:to_date])
    
    @orders = Order.find(:all, 
    :conditions => ['order_date >= ? AND order_date <= ? AND (order_status_id != ?)',
      @from_date, @to_date, Order::ORDER_STATUS_CANCELED],
    :order => 'order_date DESC')
    
  @shipping = @orders.empty? ? Money.new(0) : @orders.sum {|o| o.shipping }
  @total = @orders.empty? ? Money.new(0) : @orders.sum {|o| o.grand_total}
  calc = ((@shipping.to_s.to_f / @total.to_s.to_f) * 100).to_s
  @percentage = calc[0, calc.rindex(".") + 3] + "%"
    
  else  
    @from_date = 6.days.ago
    @to_date   = Time.now
  end #end if request.post?
  
  
    
  end #end method shipping_over_total
  
  
  def reorder
    @product_variations = ProductVariation.find(:all, :conditions => ['qty_on_hand <= reorder_qty'], :include => [:product])
    @product_variations.reject!{|pv| pv if pv.product.blank? }
    @product_variations.sort! {|x,y| x.full_title <=> y.full_title}
    
    if params[:export]
		  headers['Content-Type'] = "application/vnd.ms-excel" 
      headers['Content-Disposition'] = 'attachment; filename="inventory-reorder-export.xls"'
      headers['Cache-Control'] = ''
      render :partial => "reorder_export", :layout => false and return
	  end
	  
  end #end method reorder
  
  
  def price_list
    
    if request.post? || request.put?
      
      @file_name = "price_list_"
      @variations = ProductVariation.find(:all, :include => [:product])
      @variations.reject!{|x| x if x.product.blank?}
      
      if params[:inv_only]
        @file_name += "inv_products_only"
        @variations.reject! {|x| x.product.drop_ship}
      else
        @file_name += "all_products"
      end
      
      @variations.sort! {|x,y| x.full_title <=> y.full_title}
      
      #variation.product.subcategories.first.name
      #variation.product.subcategories.first.category.name
      
      headers['Content-Type'] = "application/vnd.ms-excel" 
      headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xls\""
      headers['Cache-Control'] = ''
      
      render :partial => "price_list_excel", :layout => false and return
      
    end #end if post
    
  end #end price_list
  
  
  def giftcard_report
    
    if request.post? || request.put?
      @from_date = Time.parse(params[:from_date])
      @to_date   = Time.parse(params[:to_date])
    else  
      @from_date = Date.today.beginning_of_month
      @to_date   = Date.today.end_of_month
    end #end if request.post?
    
    
    @valid = GiftCard.all(:conditions => ["int_current_amount > 0 AND ((expires = 1 AND expiration_date > ?) OR (expires = 0))", Date.today])
    @expired = GiftCard.all(:conditions => ["int_current_amount > 0 AND expires = 1 AND expiration_date <= ? AND expiration_date <= ?", @from_date, @to_date])
    
  end #end method giftcard_report
  
end #end class