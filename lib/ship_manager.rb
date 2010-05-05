class ShipManager
  
  
  def self.get_rate(subtotal, service_type = :standard)
    
    @shipping_total = ShippingRatesTable.get_rate(subtotal, service_type)
    return @shipping_total
    
  end #end method self.get_rate
  
  
  
  def self.courier_quote(sender_zip, to_zip, length, width, height, weight, num_packages)
    self.fedex_quick_quote(sender_zip, to_zip, length, width, height, weight, num_packages)
  end #end method self.courier_quote


  
  def self.calculate_shippments(item_list, ship_to_zip_code)
    
    ship_packages = [] #array to hold product packages that will be shipped for the order
    origin_zip = '' #string to contain the origin zipcode for the packages that aren't drop shipped
    drop_ship_cart_items = [] #array to hold cart items that have a dropship product


    for item in item_list
      
      _variation = item.variation
      
      if _variation.product.drop_ship
        drop_ship_cart_items << item
      else

        origin_zip = _variation.product.warehouse.zipcode

        #add the cart items product packages to the main packages array.  We do this in a loop
        #because if a product has 1 package, and the cart item's qty is 2, we are going to have
        #2 packages.
        0.upto(item.quantity - 1) do |q|

          #add the packages
          item.variation.product_packages.each_with_index do |pack, i| 
          
            #if a product option has a weight increase add it to the 1st product package
            if i == 0 && !item.order_line_item_options.empty?
              item.order_line_item_options.each do |ov| 
                pack.reset_weight
                pack.weight += ov.weight_increase
              end
            end
            
            ship_packages << pack
          end

          #TODO: We need a way to check and see if any options that are on the cart 
          # item require any extra space. We already have a weight and price increase, 
          # but we will need to alter ProductOption objects to have allotment for extra 
          # space required by the option

        end #end upto block
      
      end #end if drop_ship

    end #end for loop
    

    #now we take all the packages that are NOT drop shipped and send them to the packing configurator to box them
    #up.  This should give back one shippment but we may add more shippments w/ the drop shippers below
    @shippments = []
    @shippments << ShippingContainerConfigurator.calculate_assignment(ship_packages, origin_zip) unless ship_packages.empty?
    
    
    #array to hold a hash which will have unique warehouses and all the ProductPackages that ship from that 
    #warehouse.  Keys in the hash are 'warehouse' => Warehouse and 'packages' => Array(ProductPackages)
    drop_ship_packages = []
    
    #loop over the cart items that are drop ship
    drop_ship_cart_items.each do |ditem|
      
      #get a list of packages & the warehouse
      warehouse = ditem.variation.product.warehouse
      packages = []
      0.upto(ditem.quantity - 1) do |q|
        ditem.variation.product_packages.each_with_index do |pack, i| 
       
          #if a product option has a weight increase add it to the 1st product package
          if i == 0 && !ditem.order_line_item_options.empty?
            ditem.order_line_item_options.each do |ov| 
              pack.reset_weight
              pack.weight += ov.weight_increase
            end
          end
          
          packages << pack
        end
      end

      #find the warehouse in the list, if found then add these packages to the list that
      #already come from that warehouse.  If it isn't found then add it to the list
      found = drop_ship_packages.find {|entry| entry['warehouse'] == warehouse}
      if found
        found['packages'] += packages
      else
        drop_ship_packages << Hash['warehouse' => warehouse, 'packages' => packages]
      end
      
    end #end loop over drop ship cart items.
    
    
    #loop over the drop ship packages array of hashes
    drop_ship_packages.each do |dropper|
      
      #create a shippment from this warehouse.
      shippment = ShippingShippment.new(dropper['warehouse'].zipcode, true)
      
      #group the packages into ones that ship separately and one that ship together
      package_separates = dropper['packages'].group_by {|package| package.ships_separately}
     
      package_separates.each do |separate, packages|
      
        if separate == true
          
          #all the packages are to be shipped separately so add packages in a loop
          for package in packages
            shippment.add_parcel(ShippingParcel.new(package, true))
          end
          
        else
          
          #all these packages do NOT ship separately so we'll assume they all get boxed together
          #adding one parcel that is the cume weight of all the packages
          #shippment.add_parcel(ShippingStandardParcel.new(packages.sum{|p| p.weight}, false, packages))
          #
          # => code has been refactored - see below
          
          #add these packages in a loop, and keep the weight down to below our max standard parcel weight of
          # xxx lbs held in => APP_CONFIG['shipping_settings']['drop_ship_alone'].to_f
          
          #sort the packages from heaviest to lightest
          packages.sort! {|x,y| y.weight <=> x.weight}
                   
          #array to hold packages until their weight is more than our limit
          temp_package_group = [] 
        
          #loop over the packages and add them to the shippment
          packages.each_with_index do |package, i|

            #if the group is empty just add the package
            if temp_package_group.length == 0
              temp_package_group << package
            else

              # if the package group is NOT empty
              # see if the additional weight of this package will
              # make us go over the limit.
              added_weight = package.weight
              temp_package_group.each {|p| added_weight += p.weight}

              #if additional weight of the this packages makes the total go over the limit
              #we need to put the current tmp packages into a parcel & add to shippment.
              if added_weight > APP_CONFIG['shipping_settings']['drop_ship_alone'].to_f

                t_weight = 0
                temp_package_group.each{|p| t_weight += p.weight}
                #add the current temp packages to the shippment
                shippment.add_parcel(
                  ShippingStandardParcel.new(
                    t_weight, false, temp_package_group))

                #clear the temp packages
                temp_package_group.clear

                #now add this package to a fresh group
                temp_package_group << package

              else
                #just add the package since it is ok on weight
                temp_package_group << package
              end

            end #end if temp_package_group is empty

          end #end new loop


          #now we need to add any left over packages to the shippment
          unless temp_package_group.length == 0

            last_weight = 0
            temp_package_group.each{|p| last_weight += p.weight}
            #add the current temp packages to the shippment
            shippment.add_parcel(
              ShippingStandardParcel.new(
                last_weight, false, temp_package_group))

            #clear the temp packages
            temp_package_group.clear

          end #end unless
        

        end #end if seprate
        
      end #end each on hash
      

      @shippments << shippment
      
    end #end drop_ship loop
    
    
    return @shippments
    
  end #end method self.calculate_shippments
  
  
  def self.courier_ship_request(dest_info, length, width, height, weight, 
    num_packages, order_id, insured_value=nil, svc_type=nil, trn_type=nil)
    
    self.fedex_ship_request(dest_info, length, width, height, weight, 
      num_packages, order_id, insured_value=nil, svc_type=nil, trn_type=nil)
      
  end #end courier_ship_request
  
  
  ##
  # method to get full pricing and shipping information from fedex by making a 
  # "Ship Request".  The returned information can be used to make a label and get
  # any tracking information
  #
  # * @param Hash dest_info - hash of information about the package destination
  # * @param Float length - length of the package to ship
  # * @param Float width - width of the package to ship
  # * @param Float height - height of the package to ship
  # * @param Float weight - weight of the package to ship
  # * @param Integer num_packages - the total number of packages in the shippment
  # * @param String order_id - dormbuys order id used for reference
  # * @param Float insured_value - value to insure the package for
  # * @param String svc_type - Fedex Service type, ground, priority etc
  # * @param String trn_type - Fedex Transaction type, used with express or ground shipping
  # * @return ShippingFedex - object with rate information
  ##
  def self.fedex_ship_request(dest_info, length, width, height, weight, 
    num_packages, order_id, insured_value=nil, svc_type=nil, trn_type=nil)
      
      
      
      options ={
        :auth_key       => APP_CONFIG['fedex']['auth_key'].to_s,
        :auth_password  => APP_CONFIG['fedex']['auth_password'].to_s,
        :account_number => APP_CONFIG['fedex']['account_number'].to_s,
        :meter_number   => APP_CONFIG['fedex']['meter_number'].to_s,
        :debug          => true
      }
      
      
      
      if dest_info[:zip].length > 5
         dest_info[:zip] = dest_info[:zip].to_s[0,5]
      end
      
      #fix residential shipping > 70 lbs
      # if weight >= 70
      #         service_type = Fedex::ServiceTypes::FEDEX_GROUND
      #         residential = false
      #       else
      #         service_type = Fedex::ServiceTypes::GROUND_HOME_DELIVERY
      #         residential = true
      #       end
      service_type = Fedex::ServiceTypes::FEDEX_GROUND
      residential = false
      
      
      #dest_info[:address1] += ' ' + dest_info[:address2] if dest_info[:address2]
      
      #SETUP the destination address info
      dest_address_info = {
        :country => dest_info[:country].upcase,
        :street => dest_info[:address1],
        :state => dest_info[:state].upcase,
        :city => dest_info[:city],
        :zip => dest_info[:zip],
        :residential => residential
      }
      dest_address_info[:street2] = dest_info[:address2] unless dest_info[:address2].blank?
      
      contact_info = {
        :name => dest_info[:name],
        :phone_number => dest_info[:phone]
      }
      contact_info[:company_name] = dest_info[:company_name] if dest_info[:company_name]


      ship_fields ={
        :shipper => {
          :contact => {
            :name => 'Dormbuys.com',
            :phone_number => '18665023676'
          },
          :address => {
            :country => 'US',
            :street => '13720 Aiken Rd. Unit B',
            :state => 'KY',
            :city => 'Louisville',
            :zip => '40245'
          }
        },
        :recipient => {
          :contact => contact_info,
          :address => dest_address_info
        },
        :service_type => service_type,
        :length => length,
        :width => width,
        :height => height,
        :weight => weight,
        :reference_number => order_id
      }


      fedex = Fedex::Base.new(options)
      fedex.label(ship_fields)

  
  end #end method self.fedex_ship_request
  
  
  
  
  ##
  # method to void a fedex_ship_request (and label)
  #
  # * @param String tracking_number - tracking number of the request to void
  # * @return Boolean - T||F if request was voided
  ##
  def self.void_fedex_ship_request(tracking_number)
    
    options ={
      :auth_key       => APP_CONFIG['fedex']['auth_key'].to_s,
      :auth_password  => APP_CONFIG['fedex']['auth_password'].to_s,
      :account_number => APP_CONFIG['fedex']['account_number'].to_s,
      :meter_number   => APP_CONFIG['fedex']['meter_number'].to_s,
      :debug          => true
    }

    
    fedex = Fedex::Base.new(options)
    fedex.cancel(:tracking_number => tracking_number)
    
  end #end method self.void_fedex_ship_request(tracking_number)
  
  
  
  
  ##
  # method to get a quick price on shipping from fedex by making a "Rate Request"
  #
  # * @param String or Int sender_zip - origin zip code
  # * @param String or Int to_zip, destination zip code 
  # * @param Float length - length of the package
  # * @param Float width - width of the package
  # * @param Float height - height of the package
  # * @param Float weight - total weight of the shippment
  # * @param Int num_packages - total number of packages in the shippment
  # * @return Float - shipping rate quote from fedex for the shippment
  ##
  def self.fedex_quick_quote(sender_zip, to_zip, length, width, height, weight, num_packages)
    

    if sender_zip.blank? || 
       to_zip.blank? || 
       length.blank? || 
       width.blank? || 
       height.blank? || 
       weight.blank? || 
       num_packages.blank?
       raise "Invalid Arguments"
     end
     
     if sender_zip.length > 5
       sender_zip = sender_zip[0,5]
     end
     
     if to_zip.length > 5
       to_zip = to_zip[0,5]
     end
     
     length = length.ceil
     width = width.ceil
     height = height.ceil
     weight = weight.ceil
     
     #variable for any extra fees
     additional_fees = 0.00

     #fix residential shipping > 70 lbs
     # if weight >= 70
     #        additional_fees += 2.25
     #        service_type = Fedex::ServiceTypes::FEDEX_GROUND
     #        residential = false
     #      else
     #        service_type = Fedex::ServiceTypes::GROUND_HOME_DELIVERY
     #        residential = true
     #      end
     additional_fees += 2.25
     service_type = Fedex::ServiceTypes::FEDEX_GROUND
     residential = false

    options ={
      :auth_key       => APP_CONFIG['fedex']['auth_key'].to_s,
      :auth_password  => APP_CONFIG['fedex']['auth_password'].to_s,
      :account_number => APP_CONFIG['fedex']['account_number'].to_s,
      :meter_number   => APP_CONFIG['fedex']['meter_number'].to_s,
      :debug          => true
    }

    
    price_fields ={
      :origin => {
        :country => 'US',
        :street => ' ',
        :state => "#{self.state_from_zip(sender_zip)}",
        :city => ' ',
        :zip => sender_zip
      },
      :destination => {
        :country => 'US',
        :street => ' ',
        :state => "#{self.state_from_zip(to_zip)}",
        :city => ' ',
        :zip => to_zip,
        :residential => residential
      },
      :service_type => service_type,
      :count => num_packages, 
      :weight => weight,
      :length => length,
      :width => width,
      :height => height,
    }
    

      #actually calculate shipping
      fedex = Fedex::Base.new(options)
      price = fedex.price(price_fields)
      final_price = ((price / 100.0) + additional_fees)
      
      
      
      
      ################################################################
      str = "\n\n[#{Time.now}]\n"                                     
      str += "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"            
      str += "ran ShipManager.fedex_quick_quote\n"                    
      str += "Sending From: #{sender_zip} To: #{to_zip}\n"            
      str += "Length: #{length}, Width: #{width}, Depth: #{height}\n" 
      str += "Weight: #{weight}\n"                                    
      str += "Number of Packages: #{num_packages}\n\n"                
      str += "PRICE: #{final_price}\n"                                
      str += "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"          
                 
      puts str                                                        
                                                                                 
      ################################################################
      
      return final_price.to_money
    
  end #end method self.fedex_quick_quote()
  
  

  
  ##
  # method to get a standard USPS rate based on weight.  the number of parcels
  # is assumed to be 1, and the weight must be under 16 ounces rounded up (1 lb).  The weight
  # is taken in pounds
  # ex:  usps_quick_quote(0.389375) #=> $2.15
  #   logic explained.  0.389375 is 6.23 ounces expressed in pounds.  The method converts it to 
  #   6.23 ounces, then runs Float#ceil to round up so 6.23 becomes 7.  Next the method looks up 
  #   the rate for 7 ounces and returns the value.
  #
  # * @param Float weight - weight expressed in LBS
  # * @return Float - USPS shipping rate for the given weight
  ##
  def self.usps_quick_quote(weight)
    
    weight *= 16 #convert lbs to ounces
    
    weight = weight.ceil #round up
    
    rates = {
      1  => 1.17, 
      2  => 1.34, 
      3  => 1.51, 
      4  => 1.68, 
      5  => 1.85, 
      6  => 2.02, 
      7  => 2.19, 
      8  => 2.36, 
      9  => 2.53, 
      10 => 2.70, 
      11 => 2.87, 
      12 => 3.04, 
      13 => 3.21,
      14 => 4.80,
      15 => 4.80,
      16 => 4.80
    }
    
    rates[weight].to_money
    
  end #end self.usps_quick_quote
  
  
  ##
  # method to get a state from a zipcode
  #
  # * @param String or Int - zip code to lookup the state for
  # * @return String - 2 letter state code for the zip code passed in
  ##
  def self.state_from_zip(zip)

  		destination = Destination.find_by_postal_code("#{zip}")
  		
  		#if destination wasn't found, return nil
  		destination ? destination.state_province : nil

  end #end method self.state_from_sip(zip)
  
  
end #end class