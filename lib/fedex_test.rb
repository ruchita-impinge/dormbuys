require 'fedex'

class FedexTest

#################################
#testing
##################################
#fedex_auth_key: LPr7f6COselT6zXQ
#fedex_account: 510087526
#fedex_meter: 1223651
##################################
#production
#################################
#fedex_password: pmdizG6iI0ypnv3EW7V9Opw94
#fedex_key: hnbs3bHzmVY0ZoIU
#fedex_account: 336114829
#fedex_meter: 4283569


  @options ={
    :auth_key       => APP_CONFIG['fedex']['auth_key'].to_s,
    :auth_password  => APP_CONFIG['fedex']['auth_password'].to_s,
    :account_number => APP_CONFIG['fedex']['account_number'].to_s,
    :meter_number   => APP_CONFIG['fedex']['meter_number'].to_s,
    :debug          => true
  }


  def self.rate_test
    
    fedex = Fedex::Base.new(@options)
    
    price_fields ={
      :origin => {
        :country => 'US',
        :street => ' ',
        :state => 'MA',
        :city => ' ',
        :zip => '02360'
      },
      :destination => {
        :country => 'US',
        :street => ' ',
        :state => 'CA',
        :city => ' ',
        :zip => '90210',
        :residential => true
      },
      :service_type => Fedex::ServiceTypes::GROUND_HOME_DELIVERY,
      :count => 1, 
      :weight => 15.0,
      :length => 12,
      :width  => 12, 
      :height => 12
    }
    
    
    price = fedex.price(price_fields)
    puts "PRICE IS: #{(price/100.0)}"
    
  end #end method self.test_price
  
  def self.ship_test
    
    fedex = Fedex::Base.new(@options)
    
    ship_fields ={
      :shipper => {
        :contact => {
          :name => 'Deryl Sweeney',
          :phone_number => '5022544324'
        },
        :address => {
          :country => 'US',
          :street => '13720 Aiken Rd',
          :state => 'KY',
          :city => 'Louisville',
          :zip => '40245'
        }
      },
      :recipient => {
        :contact => {
          :name => 'Brian Webb',
          :phone_number => '5022987961'
        },
        :address => {
          :country => 'US',
          :street => '1207 Downhill Run',
          :state => 'KY',
          :city => 'Louisville',
          :zip => '40026',
          :residential => true
        }
      },
      :service_type => Fedex::ServiceTypes::STANDARD_OVERNIGHT,
      :weight => 15.0,
      :reference_number => '911911911911'
    }
    
    price, label, tracking_number = fedex.label(ship_fields)
    puts "PRICE IS: #{(price/100.0)}"
    puts "TRK #: #{tracking_number}"

    #f = File.new("/Users/brian/Desktop/#{rand(100000000)}_fedex_label.pdf", "wb")
    #f.write File.new(label.path).read
    #f.close
    
  end #end method self.ship_test
  
  def self.cancel_shippment_test
    fedex = Fedex::Base.new(@options)
    done = fedex.cancel(:tracking_number => '800027810004488')
    puts "Shippment was#{done ? '' : ' NOT'} successfully canceled."
  end #end method cancel_shippment_test
  
  def self.address_verification_test
    
    fedex = Fedex::Base.new(@options)
    
    addy_fields = {
      :address => '1207 Downhill Run',
      :city => 'Goshen', 
      :state => 'KY', 
      :zip => '40026' 
    }
    
    fedex.verify_address(addy_fields)
  end #end method address_verification_test
  
  

end #end class