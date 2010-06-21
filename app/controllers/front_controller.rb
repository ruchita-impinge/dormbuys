class FrontController < ApplicationController
  

  def index
    @page_title = "Home"
    
    unless read_fragment("home_page_2")
      if RAILS_ENV == "development"
        @featured_products = Product.all(:limit => 20)
        @featured_products.reject!{|p| p if p.available_variations.empty? }
      else
        @featured_products = Product.random_featured_products(10)
      end
    end
    
    render :layout => 'home'
  end #end index



  def category
    
    if params[:old_site_category_id]
      begin
        @category = Category.find(params[:old_site_category_id])
      rescue
        @category = nil
      end
    else
      @category = Category.find_by_permalink_handle(params[:category_permalink_handle])
    end
    
    
  
    if @category.blank?
      flash[:error] = "Category was not found"
      redirect_to root_path and return
    end
    
    
    @page_title = @category.name
    render :layout => "front_large_banner"
  end #end category




  def subcategory
    
    if params[:old_site_subcategory_id]
      begin
        @subcategory = Subcategory.find(params[:old_site_subcategory_id])
      rescue
        @subcategory = nil
      end
    else
      @subcategory = Subcategory.find_by_permalink_handle(params[:subcategory_permalink_handle])
    end
    
    
    
    
    if @subcategory.blank?
      flash[:error] = "Subcategory was not found"
      redirect_to root_path and return
    end
    
    
    @category = @subcategory.category
    
    pids = @subcategory.product_ids
    sql = %(select distinct p.* from products p, product_variations pv where pv.product_id = p.id AND p.id IN (#{pids.join(",")}) AND pv.visible = 1 AND pv.qty_on_hand >= 1 and p.visible = 1;)
    
    unless @subcategory.has_visible_children?
      if params[:view_all]
        @products = Product.find_by_sql(sql)
        #@products = @subcategory.visible_products
      else
        @products = Product.find_by_sql(sql).paginate :per_page => 12, :page => params[:page]
        #@products = @subcategory.visible_products.paginate :per_page => 12, :page => params[:page]
      end
    end
    
    @page_title = @subcategory.name
    render :layout => "front_large_banner"
  end #end subcategory




  def product
    
    if params[:old_site_product_id]
      begin
        @product = Product.find(params[:old_site_product_id])
      rescue
        @product = nil
      end
    else
      @product = Product.find_by_permalink_handle(params[:product_permalink_handle])
    end
    
    if @product.blank?
      flash[:error] = "Product was not found"
      redirect_to root_path and return
    end
    
    if @product.available_variations.empty?
      flash[:error] = "This product is currently unavailable"
      redirect_to root_path and return
    end
    
    begin
      
      @subcategory = @product.subcategories.first
      @category = @subcategory.category
      @page_title = @product.product_name
    
    
      unless read_fragment(@product)
        @additional_images = []
        @product.additional_product_images.each do |aimg|
          @additional_images << {:thumb => aimg.image(:thumb), :main => aimg.image(:main), :large => aimg.image(:large), :title => aimg.description, :sort => 1}
        end
    
        @product.available_variations.each do |v|
          if v.image.file?
            @additional_images << {:thumb => v.image(:thumb), :main => v.image(:main), :large => v.image(:large), :title => v.title, :sort => 2}
          end
        end
    
        @additional_images.sort! {|x,y| x[:sort] <=> y[:sort]}
    
    
        @recommended_products = @product.recommended_products
      end #end read fragment
      
    rescue => e
      HoptoadNotifier.notify(
        :error_message => "!!! - Product Page Error: #{e.message}",
        :parameters    => params
      )
      flash[:error] = "There was an error loading the product you requested"
      redirect_to root_path and return
    end
      
    render :layout => "front_large_banner"
  end #end product
  
  
  
  def search
    @page_title = "Search"
    
    if params && params[:search] && params[:search][:search_term]
      found_products = Product.all(:conditions => ["visible = ? AND product_name LIKE ?", true, "%#{params[:search][:search_term]}%"])
      parsed_products = found_products.reject {|p| p if p.available_variations.empty? }
      @products = parsed_products.paginate :per_page => 12, :page => params[:page]
    else
      @products = [].paginate :per_page => 12, :page => params[:page]
    end
    
    render :layout => "search"
    
  end #end method search
  
  
  #ajax method
  def email_list_signup
    render :update do |page|

      mail_client = EmailListClient.find_by_email(params[:email_list][:email_address])
      if mail_client
        page.alert("You're already on the mailing list!")
      else
        new_mail_client = EmailListClient.new(:email => params[:email_list][:email_address])
        if new_mail_client.save
          page.alert("Thanks for signing up!")
        else
          msgs = new_mail_client.errors.full_messages.join('\n')
          page << "alert(\"Errors:\\n#{msgs}\")"
        end
      end
      
    end
  end #end method email_list_signup
  
  
  def registry
    @page_title = "Gift Registry"
    render :layout => "front_short_banner"
  end #end method registry
  
  
  def registry_search
    @page_title = "Gift Registry"
    if params[:gift_registry_search].values.all?(&:blank?)
      flash[:error] = "You must enter a some search terms"
      redirect_to main_gift_registry_path and return
    else
      if !params[:gift_registry_search][:registry_number].blank?
        temp_registries = GiftRegistry.all(:conditions => ["registry_number LIKE ?", "#{params[:gift_registry_search][:registry_number]}%"])
      else
        
        #perform the search on name basis
        if !params[:gift_registry_search][:last_name].blank? && !params[:gift_registry_search][:first_name].blank?

          temp_registries = []
          @names = GiftRegistryName.all(:conditions => ["first_name LIKE ? AND last_name LIKE ?", "#{params[:gift_registry_search][:first_name]}%", "#{params[:gift_registry_search][:last_name]}%"])
          @names.each {|name| temp_registries << name.gift_registry }
          temp_registries.uniq!
          
        elsif !params[:gift_registry_search][:last_name].blank? && params[:gift_registry_search][:first_name].blank?
          
          temp_registries = []
          @names = GiftRegistryName.all(:conditions => ["last_name LIKE ?", "#{params[:gift_registry_search][:last_name]}%"])
          @names.each {|name| temp_registries << name.gift_registry }
          temp_registries.uniq!
          
        elsif !params[:gift_registry_search][:first_name].blank? && params[:gift_registry_search][:last_name].blank?
          
          flash[:error] = "When searching by name you must provide first and last name"
          redirect_to main_gift_registry_path and return
          
        else
          temp_registries = []
        end
        
      end
    end
    
    @gift_registries = temp_registries.paginate :per_page => 20, :page => params[:page]
    render :layout => "front_short_banner"
  end #end method search_registry
  
  
  def registry_view
    @page_title = "Gift Registry"
    @gift_registry = GiftRegistry.find(params[:id])
    
    @sort_cats = [["All Categories", 0]]
    @gift_registry.gift_registry_items.each do |item|
      if item.product_variation
        item.product_variation.product.subcategories.each do |sub|
          @sort_cats << [sub.category.name, sub.category.id]
        end
      end
    end
    
    @sort_cats.uniq!
    @sort_cats.unshift(["All Categories", 0])
    
    @items = @gift_registry.gift_registry_items
    
    #detect if sort was run
    unless params[:options].blank?
      
      if params[:options][:show_price] != "all"
        
        low, high = params[:options][:show_price].split("-")
        @items.reject! {|i| i unless i.price >= low.to_money && i.price <= high.to_money }
        
      end
        
        
      if params[:options][:show_cat].to_i != 0
        @items.reject! {|i| i unless i.product_variation && i.product_variation.product.subcategories.collect(&:category_id).include?(params[:options][:show_cat].to_i) }
      end
        
        
      if params[:options][:sort] == "product_name"
        @items.sort! {|x,y| x.product_variation.full_title <=> y.product_variation.full_title}
      elsif params[:options][:sort] == "price"
        @items.sort! {|x,y| x.price <=> y.price}
      end
        
        
    end #end if no options
    
    render :layout => "front_short_banner"
  end #end method registry_view
  
  
  def registry_add_to_cart
    find_cart
    @gift_registry = GiftRegistry.find(params[:id])
    items = params[:gift_registry_purchase][:gift_registry_item_attributes]
    for item in items
      if item[:buy_qty].to_i > 0
        gr_item = @gift_registry.gift_registry_items.find(item[:id])
        gr_item.buy_qty = item[:buy_qty].to_i
        @cart.add(gr_item.to_cart_item_params)
      end
    end
    redirect_to cart_path and return
  end #end method registry_add_to_cart
  
  
#vendor packing list

  def vendor_packing_list
    
    err_msg = "Unable to load order.  Try to cut and paste the full URL from the email into your browser."
    
    #figure out which decryption method do use
    if params[:code].rindex("D")
      data = Security::SecurityManager.simple_decrypt(params[:code])
    else
      begin
        data = Security::SecurityManager.decrypt(params[:code])
      rescue
        flash[:error] = err_msg
        redirect_to root_path and return
      end
    end
      
      
    #make sure we decrypt right
    vendor_id, order_id = data.split("-").collect {|id| id.to_i}
    unless vendor_id && order_id
      flash[:error] = "Vendor or Order could not be found."
      redirect_to root_path and return
    end


    #make sure we have the order
    begin
      @order = Order.find(order_id.to_i)
    rescue
      flash[:error] = err_msg
      redirect_to root_path and return
    end
    
    
    #make sure we have the vendor
    begin
      @vendor = Vendor.find(vendor_id.to_i)
    rescue
      flash[:error] = "Couldn't find the vendor for this order"
      redirect_to root_path and return
    end
    
    
=begin
    unless @vendor.orders.include? @order
      flash[:error] = "Invalid Order Selection"
      redirect_to root_path and return
    end
=end
    
    @vendor_access = true
    render :partial => "shared/packing_list.html.erb", :layout => "packing_list"
  end #end method vendor_packing_list
  
  
  
#static pages

  def affiliates
    @page_title = "Affiliates"
    render :layout => "front_short_banner"
  end #end method affiliates
  
  
  def links
    @page_title = "Links"
    render :layout => "front_short_banner"
  end #end method links
  
  
  def news
    @page_title = "News"
    render :layout => "front_short_banner"
  end #end method news
 
 
  def scholarships
    @page_title = "Scholarships"
    render :layout => "front_short_banner"
  end #end method scholarships


  def contact
    @page_title = "Contact"
    @contact_message = ContactMessage.new
    render :layout => "front_short_banner"
  end #end method contact
  
  
  def contact_submit
    @contact_message = ContactMessage.new(params[:contact_message])
    if @contact_message.valid?

      #send the contact message email
      Notifier.send_later(:deliver_contact, 
        @contact_message.name, 
        @contact_message.email, 
        @contact_message.subject, 
        @contact_message.message
      )

      flash[:notice] = "Thanks! We'll respond to your message shortly"
      redirect_to contact_path and return
    else
      render :action => 'contact', :layout => "front_short_banner"
    end
  end #end method contact_submit
  
  
  def faq
    @page_title = "FAQ"
    render :layout => "front_short_banner"
  end #end method faq
  
  
  def returns
    @page_title = "Returns"
    render :layout => "front_short_banner"
  end #end method returns
  
  
  def privacy
    @page_title = "Privacy Policy"
    render :layout => "front_short_banner"
  end #end method privacy
  
  
  def security
    @page_title = "Security"
    render :layout => "front_short_banner"
  end #end method security
  
  
  def shipping
    @page_title = "Shipping"
    render :layout => "front_short_banner"
  end #end method shipping
  

  
#external redirects (we redirect so we can control https vs http)

  def blog
    redirect_to APP_CONFIG['blog_location']
  end #end method blog
  
  
  def twitter
    redirect_to "http://twitter.com/dormbuys"
  end #end method twitter
  
  
  def facebook
    redirect_to "http://tinyurl.com/6xtsyf"
  end #end method facebook
  
  

end #end class
