class FrontController < ApplicationController
  
  def home
    @page_title = "Home"
  end

  def category
    @page_title = "XYZ Category"
  end

  def subcategory
    @page_title = "ABC Sub-Category"
  end

  def product
    @page_title = "ABC 123 Product"
  end

end
