class ShippingShipment
  
  attr_reader :items, :origin, :drop_ship, :courier
  
  def initialize(origin_zip=nil, drop_ship=false)
    @origin = origin_zip
    @drop_ship = drop_ship
    @items =[] #array of Parcel objects.
    @courier = Courier.current_courier
  end #end method initialize
  
  def courier=(c)
    @courier = c
  end #end method courier=(c)
  
  
  def add_parcel(parcel)
    @items << parcel
  end #end method add_parcel(parcel)
  

end #end class