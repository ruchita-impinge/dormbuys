require 'base64'
require 'fileutils'
require 'tempfile'
require 'active_shipping'

class ShipManager
  
  include ActiveMerchant::Shipping
  
  
  def self.get_rate(subtotal, service_type = :standard)
    
    @shipping_total = ShippingRatesTable.get_rate(subtotal, service_type)
    return @shipping_total
    
  end #end method self.get_rate
  
    
  def self.courier_quote(sender_zip, to_zip, length, width, height, weight, num_packages)
    
    raise "UPS quote not implemented"
    
  end #end method self.courier_quote


  def self.calculate_shippments(item_list, ship_to_zip_code)
    
    ship_packages = [] #array to hold product packages that will be shipped for the order
    origin_zip = '' #string to contain the origin zipcode for the packages that aren't drop shipped
    drop_ship_cart_items = [] #array to hold cart items that have a dropship product


    for item in item_list
      
      _variation = item.variation
      
      if _variation.blank? || _variation.product.blank?
        break
      end
      
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
      shippment = ShippingShipment.new(dropper['warehouse'].zipcode, true)
      
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
    
    self.ups_ship_request(dest_info, length, width, height, weight, num_packages, order_id, insured_value, svc_type, trn_type)
    
  end #end courier_ship_request
  
  
  def self.void_shipping_label(shipping_label)
    
    ShipManager.void_ups_ship_request(shipping_label.identification_number, shipping_label.tracking_number)
        
  end #end void_shipping_label
  
  
  def self.state_from_zip(zip)

  		destination = Destination.find_by_postal_code("#{zip}")
  		
  		#if destination wasn't found, return nil
  		destination ? destination.state_province : nil

  end #end method self.state_from_sip(zip)
  
  
  
  
#-------------------------- CARRIER SPECIFIC BELOW -------------------------------------

  def self.void_ups_ship_request(identification_number, tracking_number)
    
    ups_login         = APP_CONFIG['ups']['login'].to_s
    ups_pass          = APP_CONFIG['ups']['password'].to_s
    ups_key           = APP_CONFIG['ups']['key'].to_s
    ups_origin_number = APP_CONFIG['ups']['origin_number'].to_s
    ups_testing       = APP_CONFIG['ups']['testing'].to_i == 1

    #create the UPS object
    @ups = UPS.new(:login => ups_login, :password => ups_pass, :key => ups_key)
    
    @ups.void_shipment(identification_number, [tracking_number], {:test => ups_testing})
    
  end #end method self.void_ups_ship_request(identification_number, tracking_number)


  def self.ups_ship_request(dest_info, length, width, height, weight, num_packages, order_id, insured_value=nil, svc_type=nil, trn_type=nil)
    
    ups_login         = APP_CONFIG['ups']['login'].to_s
    ups_pass          = APP_CONFIG['ups']['password'].to_s
    ups_key           = APP_CONFIG['ups']['key'].to_s
    ups_origin_number = APP_CONFIG['ups']['origin_number'].to_s
    ups_testing       = APP_CONFIG['ups']['testing'].to_i == 1
    
    #######
    ### SETUP FOR GROUND BY DEFAULT
    #######
    carrier_service = svc_type.blank? ? "03" : svc_type
    
    #create the UPS object
    @ups = UPS.new(:login => ups_login, :password => ups_pass, :key => ups_key)
    
    
    #setup the packages
    packages = [Package.new((weight * 16),[length, width, height], :units => :imperial)]
    
    
    #set the label spec
    label_specification = {:print_code => "GIF", :format_code => "GIF", :user_agent => "Mozilla/4.5"}
    
    
    #scrub the zip
    if dest_info[:zip].length > 5
       dest_info[:zip] = dest_info[:zip].to_s[0,5]
    end
    
    #setup destination and origin
    options = {
      :origin => {
        :address_line1 => "1110 Avoca Station Court", 
        #:address_line2 => "", 
        :country => 'US', 
        :state => 'KY',
        :city => 'Louisville',
        :zip => '40245', 
        :phone => "(502) 254-4324", 
        :name => "Dormbuys.com", 
        :attention_name => "Ship & Rec.", 
        :origin_number => ups_origin_number
      }, 
      :destination => {
        :company_name => (dest_info[:company_name] ? dest_info[:company_name] : dest_info[:name]),
        :attention_name => dest_info[:name],
        :phone => dest_info[:phone], 
        :address_line1 => dest_info[:address1], 
        #:address_line2 => "", 
        :country => dest_info[:country].upcase, 
        :state => dest_info[:state].upcase, 
        :city => dest_info[:city], 
        :zip => dest_info[:zip]
        }, 
      :test => ups_testing
    }
    options[:destination][:address_line2] = dest_info[:address2] unless dest_info[:address2].blank?
    
    
    confirm_response = @ups.shipment_confirmation_request(carrier_service, packages, label_specification, options)
    
    accept_response = @ups.shipment_accept_request(confirm_response.digest, {:test => ups_testing})
    
    identification_number = confirm_response.identification_number
    
    return_array = []
    
    accept_response.shipment_packages.each do |package|
      
      #gives you the base64 code for html label
    	html_image = package.html_image 
    	
    	#gives you the base64 code for graphic label
    	graphic_image = package.graphic_image 
    	
    	#gives you the images format(gif/png)
    	label_image_format = package.label_image_format 
    	
    	#gives you the tracking number of package
    	tracking_number = package.tracking_number 
    	
    	
    	#write out the GRAPHIC file
    	label_tmp_file = Tempfile.new("shipping_label")
      label_tmp_file.write Base64.decode64(graphic_image)
      label_tmp_file.rewind
      
      #write out the HTML file
      html_tmp_file = Tempfile.new("shipping_label_html")
      html_tmp_file.write Base64.decode64(html_image)
      html_tmp_file.rewind
      
      FileUtils.mkdir_p(SHIP_LABELS_STORE) unless File.exists?(SHIP_LABELS_STORE)
      
      #save the GRAPHIC file
      graphic_filename = "#{SHIP_LABELS_STORE}/label#{tracking_number}.#{label_image_format.downcase}"
      graphic_url = "#{WEB_LABEL_REPOSITORY}/label#{tracking_number}.#{label_image_format.downcase}"
      gf = File.new(graphic_filename, "wb")
      gf.write File.new(label_tmp_file.path).read
      gf.close
      
      #save the HTML file
      html_filename = "#{SHIP_LABELS_STORE}/#{tracking_number}.html"
      html_url = "#{WEB_LABEL_REPOSITORY}/#{tracking_number}.html"
      hf = File.new(html_filename, "wb")
      hf.write File.new(html_tmp_file.path).read
      hf.close
      
      return_array = [html_url, tracking_number, identification_number]
 
    end #end shipment_packages.each
    
    return return_array
    
  end #end method self.ups_ship_request(dest_info, length, width, height, weight)


  

  
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
  
  
  
  
  
end #end class