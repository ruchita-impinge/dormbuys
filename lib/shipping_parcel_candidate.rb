class ShippingParcelCandidate
  
  attr_reader :length, :width, :depth, :weight, :min_container, :product_package
  
  ##
  # * @param Float l - length of the product package w/ padding
  # * @param Float w - width of the product package w/ padding
  # * @param Float d - depth of the product package w/ padding
  # * @param Float wht - weight of the product package
  # * @param ShippingContainer min_container - the smallest shipping container that this product package can fit into
  # * @param ProductPackage pp - product package being shipped
  ##
  def initialize(l, w, d, wht, min_container, pp)
    @length = l
    @width = w
    @depth = d
    @weight = wht
    @min_container = min_container
    @product_package = pp
  end #end method initialize(box, min_container)
  
  
  def volume
    @length * @width * @depth
  end #end method volume
  
  
  def min_container_vol
    @min_container.volume
  end #end method min_container_vol
  
  
end #end class