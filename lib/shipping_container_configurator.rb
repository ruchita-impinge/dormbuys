##
# ContainerConfigurator class is used to figure out the most effecient way to take 
# a collection of packages and and pack them into shipping containers of various sizes.
##
class ShippingContainerConfigurator
  
  
  ##
  # method to...
  #
  # * @param Array packages - an array of ProductPackage objects which will need to be boxed
  # * @param String origin - origin zip code from where all the packages will be shipped
  ##
  def self.calculate_assignment(packages, origin)
    
    origin = origin[0,5]

    #make a new shippment
    @shippment = ShippingShipment.new(origin)
    
    ##
    # create a Proc to assign items to a container and shippment
    #
    # * @param ShippingContainer container - shipping container to pack items into
    # * @param Array items - array of ParcelCandidate objects to pack
    ##
    pack_items = Proc.new do |container, items|
    
      #create a new parcel the size of the min container
      parcel = ShippingParcel.new(container)

      #put all the parcel_candidate items into the parcel
      items.each {|pc| parcel.add_item(pc)}

      #add the parcel to the shippment
      @shippment.add_parcel(parcel)
    
    end #end Proc
    
    
    #get all the shipping containers
    @containers = ShippingContainer.find(:all)
    
    #sort the containers from smallest to largest
    @containers.sort! do |x,y|
      x.volume <=> y.volume
    end #end sort
    
    #array to hold Product Package & the smallest box that package can go into,
    #array is of ParcelCandidate objects
    @parcel_candidates = []
    
    padding = APP_CONFIG['shipping_settings']['container_item_padding']
    
    packages_to_remove = [] #array to hold indexes to remove from packages array
    
    #for each of the packages figure out the minimum size container it could go in alone
    #then make a container item for it
    packages.each_with_index do |box, i|
      
      if box.ships_separately
        @shippment.add_parcel(Parcel.new(box, true))
        packages_to_remove << i
      else
      
        #calculate the padded dims of the product we are packing
        padded_l = box.length + padding
        padded_w = box.width + padding
        padded_d = box.depth + padding

        #loop through the containers & find smallest one the box can go in alone
        #we start with the smallest container so if the package fits you have it
        @containers.each do |cont|
 
          # we have 3 dimensions to compare to the container but we want to look at the 
          # different rotational aligments that the package could be palced into the container
          # so we must compare each dimension to each other dimension to be sure there is no
          # orientation of the package that will fit in the container before moving to the next
          # container
 
          #try first orientation
          if padded_l <= cont.length && padded_w <= cont.width && padded_d <= cont.depth && cont.dimensional_weight == false
            
            @parcel_candidates << ShippingParcelCandidate.new(padded_l, padded_w, padded_d, box.weight, cont, box)
            packages_to_remove << i
            break
            
          #try second orientation
          elsif padded_d <= cont.length && padded_l <= cont.width && padded_w <= cont.depth && cont.dimensional_weight == false
            
            @parcel_candidates << ShippingParcelCandidate.new(padded_d, padded_l, padded_w, box.weight, cont, box)
            packages_to_remove << i
            break
            
          #try third orientation
          elsif padded_w <= cont.length && padded_d <= cont.width && padded_l <= cont.depth && cont.dimensional_weight == false
            
            @parcel_candidates << ShippingParcelCandidate.new(padded_w, padded_d, padded_l, box.weight, cont, box)
            packages_to_remove << i
            break
            
          end #end if statement
        
        end #end @containers.each
      
      end #end if pack.ships_separately
     
    end #end packages.each
    
    #now remove any packages that were added to parcel_candidates, we can't just delete them from the indexes
    #because when we delete one the whole index map of the array will change.  So we mark the ones to delete
    #then remove all that are marked
    packages_to_remove.each {|i| packages[i] = nil}
    packages.delete(nil)
    
    #from here anything left in packages we are going to assume will ship alone even though it didn't explicitly
    #say so, we don't have a box that will fit it, so that is what it will get
    packages.each do |pack|
      @shippment.add_parcel(ShippingParcel.new(pack, true))
    end
    
    #now we should have everything in the "packages" taken care of, but just to be sure lets clear it
    packages.clear

    
    #now lets pack some stuff if we have any
    unless @parcel_candidates.empty?
    
    
      #ok so now we have a collection of ParcelCandidate objects in "@parcel_candidates". Now we need to find out
      #how to box the items relative to the smallest box they can go in.  We sort them by largest minimum
      #sized container to smallest
      @parcel_candidates.sort! {|x,y| y.min_container_vol <=> x.min_container_vol}
    
    
      #see if the entire order can fit into the largest minimum size container, we do this comparison
      #based on VOLUME so it isn't 100% accurate
      if @parcel_candidates.first.min_container_vol >= @parcel_candidates.sum {|candidate| candidate.volume }
      
        #add all the candidates to this container
        pack_items.call(@parcel_candidates.first.min_container, @parcel_candidates)
        
      
      else
        #ok, so all the items can't fit into the largest min container
        #we have to move to a bigger container.  So find the smallest container that fits the 
        #ENTIRE order & is not dim weight BUT is still larger than the largest min size container.
        #Note: containers are still sorted from smallest to largest.
        new_container = @containers.detect do |container|
        
          container.dimensional_weight == false &&
          (container.volume >= @parcel_candidates.sum {|candidate| candidate.volume }) &&
          (container.volume >= @parcel_candidates.first.min_container_vol)

        end #end containers.detect
      
      
        #if we have a container we can fit everything in
        if new_container
        
          #add all the candidates to this container
          pack_items.call(new_container, @parcel_candidates)
        
        else
        
          #now it looks like we don't nave ANY boxes (non-dim-weight) that are big enough to 
          #pack this entire order into, so we need to split it up.  We sort the parcel_candidates
          #by largest to smallest then we start with the largest box, fill it, then work on the rest.
          @parcel_candidates.sort! {|x,y| y.volume <=> x.volume}
        
          #containers are still sorted from smallest to largest so we'll reverse them
          #to get largest first
          @containers.reverse!
        
          #find the largest non-dim container
          largest = @containers.detect {|c| c.dimensional_weight == false}
          parcel = ShippingParcel.new(largest)
          
          #now load the container until it is full, removing the parcel candidates as they are loaded
          until @parcel_candidates.empty?
          
            candidate = @parcel_candidates.shift
          
            #if the parcel has room for the candidate packages
            #add it to the parcel
            if parcel.available_volume >= candidate.volume
              parcel.add_item(candidate)
              
            else
              
              #if we are here then the parcel doesn't have any more room so we add it to the 
              #shippment and get a new parcel item
              @shippment.add_parcel(parcel)
            
              #now we need to find a new container to use as a parcel for any remaining parcel_candidates
              #sort parcel candidates by largest min-container-volume first.  We need to use the current candidate
              #in this calculation though so we add it back in
              @parcel_candidates.unshift(candidate)
              @parcel_candidates.sort! {|x,y| y.min_container_vol <=> x.min_container_vol}
            
              #see if the entire remaining order can fit into the largest minimum size container
              if @parcel_candidates.first.min_container_vol >= @parcel_candidates.sum {|candidate| candidate.volume }

                #add all the remaining candidates to this container
                pack_items.call(@parcel_candidates.first.min_container, @parcel_candidates)
                @parcel_candidates.clear #remove all the parcle_candidates cause we just packed them all
              else
              
                #we can't fit everything into the largest min size container so we need to see if we can
                #fit the entire remaining order into any box.  Lets see if the candidates total volume is less
                #than the largest box we have.  If it is we'll find the best container to use, if not we'll
                #loop again using the largest one
                if @parcel_candidates.sum {|candidate| candidate.volume } > largest.volume
                  parcel = ShippingShippingParcel.new(largest)
                  candidate = @parcel_candidates.shift
                  parcel.add_item(candidate)
                else
                
                  #total volume of candidates is less than the largest box so we need to find the best fit box to use & put everything there
                  #to start we need to sort the containers from smallest to largest
                  @containers.sort! {|x,y| y.volume <=> x.volume}
                
                  new_container = @containers.detect do |container|

                    container.dimensional_weight == false &&
                    (container.volume >= @parcel_candidates.sum {|candidate| candidate.volume }) &&
                    (container.volume >= @parcel_candidates.first.min_container_vol)

                  end #end containers.detect
                
                  #now we have the best fit, so everything left should fit here
                  pack_items.call(new_container, @parcel_candidates)
                  @parcel_candidates.clear
                
                end #end sum > largest.vol
              
              end #end if parcel_candidates.first.min_container_vol
            
            end #end if parcel.available_vol
          
          end #end until parcel_candidates.empty?
        
        
        end #end if new_container
      
      end #end if order will fit into the largest min size container
    
    end #end unless @parcel_candidates.empty?
    
    #return the shippment
    @shippment
    
  end #end self.calculate_assignment
  
  
end #end class ContainerConfigurator