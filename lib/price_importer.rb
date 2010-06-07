class PriceImporter
  
  def self.run_import
    
    csv_file = File.join(File.dirname(__FILE__), "pricing_bonanza_new.csv")
    
    #read the csv file into a variable
    data = File.new(csv_file).read


    #get each row into an array
    data_array = data.split("\r")


    #get the 1st row for the  col keys
    keys = data_array[0].split(",")

    #now lets make a hash of the numbers so we can reference the columns
    data_keys = Hash.new
    counter = 0

    #construct the hash
    keys.each do |key| 
    	data_keys[key] = counter
    	counter += 1
    end


    #now shift the key row off the top of the data_array
    data_array.shift
    
    #array to hold records not found
    not_found = []
    
    #array to hold un-saved (error) records
    unsaved = []
    
    data_array.each do |row|

    	#get the individual cells
    	cells = row.split(",")
    	
    	cells.each do |c|
    	  c.gsub!("\n","")
    	  c.gsub!("\r","")
  	  end
  	  
  	  # ALL CELLS 
  	  #----------------------
  	  # product_number,
  	  # mfg_number,
  	  # product_name,
  	  # vendor,
  	  # wholesale_price,
  	  # freight_in,
  	  # drop_ship_fee,
  	  # total_wholesale_price,
  	  # markup,
  	  # retail_price,
  	  # shipping_in_price,
  	  # total_retail_price,
  	  # rounded_retail_price,
  	  # previous_price
  	  
      #setup our variables
      product_number          = cells[0].rstrip.reverse.rstrip.reverse #
      mfg_number              = cells[1].rstrip.reverse.rstrip.reverse
      product_name            = cells[2].rstrip.reverse.rstrip.reverse
      vendor_name             = cells[3].rstrip.reverse.rstrip.reverse
      wholesale_price         = cells[4].rstrip.reverse.rstrip.reverse #
      freight_in              = cells[5].rstrip.reverse.rstrip.reverse #
  	  drop_ship_fee           = cells[6].rstrip.reverse.rstrip.reverse #
  	  total_wholesale_price   = cells[7].rstrip.reverse.rstrip.reverse
  	  markup                  = cells[8].rstrip.reverse.rstrip.reverse #
  	  retail_price            = cells[9].rstrip.reverse.rstrip.reverse
  	  shipping_in_price       = cells[10].rstrip.reverse.rstrip.reverse #
  	  total_retail_price      = cells[11].rstrip.reverse.rstrip.reverse
  	  rounded_retail_price    = cells[12].rstrip.reverse.rstrip.reverse
  	  previous_price          = cells[13].rstrip.reverse.rstrip.reverse #


      variation = ProductVariation.find_by_product_number(product_number)
      
      if variation.blank?
        variation = ProductVariation.find_by_product_number("0#{product_number}")
      end
      
      if variation.blank?
        variation = ProductVariation.find_by_product_number("00#{product_number}")
      end
      
      if variation.blank?
        variation = ProductVariation.find_by_product_number("000#{product_number}")
      end
      
      if variation.blank?
        variation = ProductVariation.find_by_product_number("00000#{product_number}")
      end
      
      
      if variation
        
        variation.wholesale_price   = wholesale_price.to_money
        variation.freight_in_price  = freight_in.to_money
        variation.drop_ship_fee     = drop_ship_fee.to_money
        variation.shipping_in_price = shipping_in_price.to_money
        variation.list_price        = previous_price.to_money
        variation.markup            = markup.to_f.to_d
        
        unless variation.save(false)
          unsaved << variation
        end
        
      else
        not_found << {:product_number => product_number, :product_name => product_name}
      end

  	end #end loop
  	
  	#print out the not founds
  	if not_found.size > 0
  	  puts "\n\n--------------[ NOT FOUND ]-----------"
	  end
  	not_found.each do |nf|
  	  puts "Could not find: #{nf[:product_name]} (#{nf[:product_number]})"
	  end
	  
	  #print out the ones with errors
	  if unsaved.size > 0
	    puts "\n\n--------------[ UNSAVED ]-----------"
    end
    unsaved.each do |v|
      puts "#{v.id}: #{v.errors.full_messages.join(", ")}"
    end
  	

  end #end method self.run_import
  
end #end class