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
  

end #end class
