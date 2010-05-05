class ShippingParcel
  
  attr_reader :length, :width, :depth, :weight, :items, :ship_alone
  
  ##
  # * @param ShippingContainer or ProductPackage container - container to ship, its only a ProductPackage if ship_alone = true
  # * @param Boolean ship_alone - tells if the ShippingParcel ships alone or not
  ##
  def initialize(container, ship_alone=false)
    @container = container
    @length = container.length
    @width = container.width
    @depth = container.depth
    @weight = container.weight
    @ship_alone = ship_alone
    @items = [] #array of ProductPackage objects contained in this parcel
    @items << container if ship_alone #add the ProductPackage to items, we know it is ProductPackage because ship_alone == true
  end #end method initialize(container, ship_alone=false)
  
  
  def total_volume
    @length * @width * @depth
  end #end method total_volume
  
  
  def occupied_volume
    @items.sum {|item| item.length * item.width * item.depth }
  end #end method occupied_volume
  
  
  def available_volume
    total_volume - occupied_volume
  end #end method available_volume
  
  
  ##
  # Add an item to the ShippingParcel
  #
  # * @param ParcelCandidate item - item to add to the total ShippingParcel items
  ##
  def add_item(item)
    @items << item.product_package #add the ProductPackage contained in the ParcelCandidate to the items array
    @weight += item.weight
  end #end method add_item(item)
  
  
end #end class