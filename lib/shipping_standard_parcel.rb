class ShippingStandardParcel
  
  attr_reader :length, :width, :depth, :weight, :items, :ship_alone
  
  ##
  # * @param Float weight - total weight of this parcel
  # * @param Boolean ship_alone - wether this parcel ships alone or not
  # * @param ProductPackage or Array - product package, or array of product packages to add to this parcel
  ##
  def initialize(weight, ship_alone, packages)
    @length = 12.0
    @width = 12.0
    @depth = 12.0
    @weight = weight
    @ship_alone = ship_alone
    @items = []
    
    if packages.class == ProductPackage
      @items << packages
    elsif packages.class == Array
      packages.each {|package| @items << package }
    end
    
  end #end method initialize(container, ship_alone=false)
  
  
  def total_volume
    @length * @width * @depth
  end #end method total_volume
  
  
  def occupied_volume
    total_volume
  end #end method occupied_volume
  
  
  def available_volume
    0.0
  end #end method available_volume
  
  
end #end class StandardParcel