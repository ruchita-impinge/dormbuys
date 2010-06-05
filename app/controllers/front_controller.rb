class FrontController < ApplicationController
  

  def index
    @page_title = "Home"
    @featured_products = Product.random_featured_products(10)
    render :layout => 'home'
  end #end index



  def category
    @category = Category.find_by_permalink_handle(params[:category_permalink_handle])
  
    if @category.blank?
      flash[:error] = "Category was not found"
      redirect_to root_path
      return
    end
    
    @page_title = @category.name
    render :layout => "front_large_banner"
  end #end category




  def subcategory
    @subcategory = Subcategory.find_by_permalink_handle(params[:subcategory_permalink_handle])
    
    if @subcategory.blank?
      flash[:error] = "Subcategory was not found"
      redirect_to root_path
      return
    end
    
    @category = @subcategory.category
    @products = @subcategory.visible_products.paginate :per_page => 12, :page => params[:page]
    
    #bw hack
    if RAILS_ENV == "development"
      @products = Product.all.paginate :per_page => 12, :page => params[:page]
    end
    
    @page_title = @subcategory.name
    render :layout => "front_large_banner"
  end #end subcategory




  def product
    @product = Product.find_by_permalink_handle(params[:product_permalink_handle])
    
    if @product.blank?
      flash[:error] = "Product was not found"
      redirect_to root_path
      return
    end
    
    @subcategory = @product.subcategories.first
    @category = @subcategory.category
    @page_title = @product.product_name
    
    @recommended_products = @product.recommended_products
    render :layout => "front_large_banner"
  end #end product
  
  
  
  def search
    params[:search_term]
    raise "Search not yet implemented"
  end #end method search
  
  
  
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
      #send contact message
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
