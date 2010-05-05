#require 'rubygems'
#gem 'soap4r'
require 'soap/wsdlDriver'
require 'base64'
require 'fileutils'
require 'tempfile'

  module Fedex 
  
    class MissingInformationError < StandardError; end #:nodoc:
  
    class FedexError < StandardError; end #:nodoc
  
    # Provides access to Fedex Web Services
    class Base
    
    
      # Defines the required parameters for various methods
      REQUIRED_OPTIONS = {:base           => [:auth_key, :auth_password, :account_number, :meter_number],
                          :price          => [:origin, :destination, :service_type, :count, :weight],
                          :label          => [:shipper, :recipient, :weight, :service_type],
                          :contact        => [:name, :phone_number],
                          :address        => [:country, :street, :city, :state, :zip],
                          :ship_cancel    => [:tracking_number]}
    
    
      # Defines the relative path to the WSDL files.  Defaults assume lib/wsdl under plugin directory.
      WSDL_PATHS =  if RAILS_ENV == 'production'
                      {:price   => 'fedex/wsdl/RateService_v3.wsdl',
                       :ship    => 'fedex/wsdl/ShipService_v3.wsdl',
                       :address => 'fedex/wsdl/AddressValidationService_v2.wsdl'}
                    else
                      {:price   => 'fedex/wsdl/dev_RateService_v3.wsdl',
                       :ship    => 'fedex/wsdl/dev_ShipService_v3.wsdl',
                       :address => 'fedex/wsdl/dev_AddressValidationService_v2.wsdl'}
                    end
    
    
      # Defines the Web Services version implemented.
      WS_VERSION       = {:price =>   {:service        => 'crs',
                                       :major          => 3,
                                       :intermediate   => 0,
                                       :minor          => 0},
                                   
                          :ship =>    {:service        => 'ship',
                                       :major          => 3,
                                       :intermediate   => 0,
                                       :minor          => 0},
                                   
                          :address => {:service        => 'avail',
                                       :major          => 2,
                                       :intermediate   => 0,
                                       :minor          => 0}}
    
      #defines Web service responses that are deemed successful
      SUCCESSFUL_RESPONSES = ['SUCCESS', 'WARNING'] 
    
      DIR              = File.dirname(__FILE__)
    
      attr_accessor :auth_key,
                    :account_number,
                    :meter_number,
                    :dropoff_type,
                    :service_type,
                    :units,
                    :packaging_type,
                    :sender,
                    :debug
    
    
    
      # Initializes the Fedex::Base class, setting defaults where necessary.
      # 
      #  fedex = Fedex::Base.new(options = {})
      #
      # === Example:
      #   fedex = Fedex::Base.new(:auth_key       => AUTH_KEY,
      #                           :account_number => ACCOUNT_NUMBER,
      #                           :meter_number   => METER_NUMBER)
      #
      # === Required options for new
      #   :auth_key       - Your Fedex Authorization Key
      #   :account_number - Your Fedex Account Number
      #   :meter_number   - Your Fedex Meter Number
      #
      # === Additional options
      #   :dropoff_type       - One of Fedex::DropoffTypes.  Defaults to DropoffTypes::REGULAR_PICKUP
      #   :packaging_type     - One of Fedex::PackagingTypes.  Defaults to PackagingTypes::YOUR_PACKAGING
      #   :label_type         - One of Fedex::LabelFormatTypes.  Defaults to LabelFormatTypes::COMMON2D.  You'll only need to change this
      #                         if you're generating completely custom labels with a format of your own design.  If printing to Fedex stock
      #                         leave this alone.
      #   :label_image_type   - One of Fedex::LabelSpecificationImageTypes.  Defaults to LabelSpecificationImageTypes::PDF.
      #   :rate_request_type  - One of Fedex::RateRequestTypes.  Defaults to RateRequestTypes::ACCOUNT
      #   :payment            - One of Fedex::PaymentTypes.  Defaults to PaymentTypes::SENDER
      #   :units              - One of Fedex::WeightUnits.  Defaults to WeightUnits::LB
      #   :currency           - One of Fedex::CurrencyTypes.  Defaults to CurrencyTypes::USD
      #   :debug              - Enable or disable debug (wiredump) output.  Defaults to false.
      def initialize(options = {})
      
        check_required_options(:base, options)
      
        @auth_key         = options[:auth_key]
        @auth_password    = options[:auth_password]
        @account_number   = options[:account_number]
        @meter_number     = options[:meter_number]
                        
        @dropoff_type       = options[:dropoff_type]      || DropoffTypes::REGULAR_PICKUP
        @packaging_type     = options[:packaging_type]    || PackagingTypes::YOUR_PACKAGING
        @label_type         = options[:label_type]        || LabelFormatTypes::COMMON2D
        @label_image_type   = options[:label_image_type]  || LabelSpecificationImageTypes::PDF
        @rate_request_type  = options[:rate_request_type] || RateRequestTypes::ACCOUNT
        @payment            = options[:payment]           || PaymentTypes::SENDER
        @units              = options[:units]             || WeightUnits::LB
        @size_units         = options[:size_units]        || LinearUnits::IN
        @currency           = options[:currency]          || CurrencyTypes::USD
        @debug              = options[:debug]             || false
        @error_output       = ""
      end
    
    
    
      def verify_address(options = {})
      
        #check_required_options => when they are there
      
        address = options[:address]
        address2 = options[:address2] ? options[:address2] : nil
        city = options[:city]
        state = options[:state]
        zip = options[:zip]
      
        @params ={
          :WebAuthenticationDetail => {
            :UserCredential => {
              :Key                    => @auth_key,
              :Password               => @auth_password
            }
          },
          :ClientDetail => {
            :AccountNumber            => @account_number,
            :MeterNumber              => @meter_number,
          },
          :TransactionDetail => {
            :CustomerTransactionId    => 'AV Sample',
          },
          :Version => {
            :ServiceId                => WS_VERSION[:address][:service],
            :Major                    => WS_VERSION[:address][:major],
            :Intermediate             => WS_VERSION[:address][:intermediate],
            :Minor                    => WS_VERSION[:address][:minor]
          },
          :RequestTimeStamp           => Time.now.strftime("%Y-%m-%dT%H:%M:%S"),
          :Options => {
        	  :VerifyAddresses          => true,
        	  :CheckResidentialStatus   => true,
        	  :MaximumNumberOfMatches   => '5',
        	},
        	:AddressesToValidate => {
        	  :AddressToValidate => {
          	  :AddressId                => 'Addy 1',
              :Address => {
          	    :StreetLines            => address,
          	    :City                   => city,
          	    :StateOrProvinceCode    => state,
          	    :PostalCode             => zip,
          	    :CountryCode            => 'US',
          	    :Residential            => true
          	  }
        	  }
        	}
        }
    
    
        # Create the driver
        driver = create_driver(:address)
      
      
        result = driver.addressValidation(@params)

      
      
        successful = successful?(result)
      
        if successful
          #do something here
        else
          dispatch_error(result)
        end
    
    
      end #end verify_address
    
    
    
      # Gets a rate quote from Fedex.
      #
      #  > fedex = Fedex::Base.new(options)
      #  > price = fedex.price(fields)
      # 
      #  > price
      #  8642
      #
      # === Required options for price
      #   :origin       - Origin address.  (See below.)
      #   :destination  - Destination address. (See below.)
      #   :service_type - One of Fedex::ServiceTypes
      #   :count        - The number of packages in your shipment.
      #   :weight       - The total weight of your shipment.
      #
      # === Addresses
      # Addresses are supplied to the system as a hash as follows
      #
      #  address = {:country => 'US',
      #             :street => '1600 Pennsylvania Avenue NW'
      #             :state => 'DC',
      #             :city => 'Washington',
      #             :zip => '20500'}
      def price(options = {})
      
        # Check overall options
        check_required_options(:price, options)
      
        # Check Address Options
        check_required_options(:address, options[:origin])
        check_required_options(:address, options[:destination])
            
        # Prepare variables
        origin        = options[:origin]
        destination   = options[:destination]
        service_type  = options[:service_type]
        count         = options[:count]
        weight        = options[:weight]
        length        = options[:length]
        width         = options[:width]
        height        = options[:height]
      
        residential   = destination[:residential].nil? ? true : destination[:residential]
      
        service_type  = resolve_service_type(service_type, residential)

        @params = {
          :WebAuthenticationDetail => {
            :UserCredential => {
              :Key                    => @auth_key,
              :Password               => @auth_password
            }                         
          },                          
          :ClientDetail => {          
            :AccountNumber            => @account_number,
            :MeterNumber              => @meter_number
          },                          
          :Version => {               
            :ServiceId                => WS_VERSION[:price][:service],
            :Major                    => WS_VERSION[:price][:major],
            :Intermediate             => WS_VERSION[:price][:intermediate],
            :Minor                    => WS_VERSION[:price][:minor]
          },                          
          :Origin => {                
            :CountryCode              => origin[:country],
            :StreetLines              => origin[:street],
            :City                     => origin[:city],
            :StateOrProvinceCode      => origin[:state],
            :PostalCode               => origin[:zip]},
          :Destination => {           
            :CountryCode              => destination[:country],
            :StreetLines              => destination[:street],
            :City                     => destination[:city],
            :StateOrProvinceCode      => destination[:state],
            :PostalCode               => destination[:zip],
            :Residential              => residential
          },
          :DropoffType                => @dropoff_type,
          :ServiceType                => service_type,
          :PackagingType              => @packaging_type,
          :Payment                    => @payment,
          :Packages  => [{
              :Weight => {
                :Units                    => @units, 
                :Value                    => weight.to_f
              },
              :Dimensions => {
                :Length                   => length,
                :Width                    => width,
                :Height                   => height,
                :Units                    => @size_units
              }
          }]
        }
      
        # Create the driver
        driver = create_driver(:price)
      
        result = driver.getRate(@params)

        successful = successful?(result)
        
              
        if successful
          #discount_rate = ((result.ratedShipmentDetails.shipmentRateDetail.totalNetCharge.amount.to_f) * 100).to_i
        
          total_base_charge = ((result.ratedShipmentDetails.shipmentRateDetail.totalBaseCharge.amount.to_f) * 100).to_i
          total_surcharges = ((result.ratedShipmentDetails.shipmentRateDetail.totalSurcharges.amount.to_f) * 100).to_i
          total_taxes = ((result.ratedShipmentDetails.shipmentRateDetail.totalTaxes.amount.to_f) * 100).to_i
        
          list_rate = total_base_charge + total_surcharges + total_taxes
          list_rate
        else
          dispatch_error(result)
        end
    
      end #end method price
    
    
    
    
      # Generate a new shipment and return associated data, including price, tracking number, and the label itself.
      #
      #  fedex = Fedex::Base.new(options)
      #  price, label, tracking_number = fedex.label(fields)
      #
      # Returns the actual price for the label, the Base64-decoded label in the format specified in Fedex::Base,
      # and the tracking_number for the shipment.
      #
      # === Required options for label
      #   :shipper      - A hash containing contact information and an address for the shipper.  (See below.)
      #   :recipient    - A hash containing contact information and an address for the recipient.  (See below.)
      #   :weight       - The total weight of the shipped package.
      #   :service_type - One of Fedex::ServiceTypes
      #
      # === :shipper and :recipient
      # Shipper and recipient should be as a hash with two keys as follows:
      #
      #  shipper = {:contact => {:name => 'John Doe',
      #                          :phone_number => '4805551212'},
      #             :address => address} # See "Address" for under price.
      def label(options = {})
      
        puts options.inspect if $DEBUG
        # Check overall options
        check_required_options(:label, options)
      
        # Check Address Options
        check_required_options(:contact, options[:shipper][:contact])
        check_required_options(:address, options[:shipper][:address])
      
        # Check Contact Options
        check_required_options(:contact, options[:recipient][:contact])
        check_required_options(:address, options[:recipient][:address])
      
        # Prepare variables
        shipper             = options[:shipper]
        recipient           = options[:recipient]
      
        shipper_contact     = shipper[:contact]
        shipper_address     = shipper[:address]
      
        recipient_contact   = recipient[:contact]
        recipient_address   = recipient[:address]
      
        service_type        = options[:service_type]
        weight              = options[:weight].ceil
        length              = options[:length].ceil
        width               = options[:width].ceil
        height              = options[:height].ceil
      
        time                = options[:time] || get_ship_timestamp
      
        residential         = recipient_address[:residential] ? recipient_address[:residential] : false
      
        service_type        = resolve_service_type(service_type, residential)
      
        reference_number    = options[:reference_number] ? options[:reference_number] : ''
      
        recipient_contact_hash = {
          :PersonName                 => recipient_contact[:name],
          :PhoneNumber                => recipient_contact[:phone_number]
        }
        recipient_contact_hash[:CompanyName] = recipient_contact[:company_name] if recipient_contact[:company_name]
      
        recipient_address_hash = {
          :CountryCode                => recipient_address[:country],
          :StreetLines                => recipient_address[:street],
          :City                       => recipient_address[:city],
          :StateOrProvinceCode        => recipient_address[:state],
          :PostalCode                 => recipient_address[:zip],
          :Residential                => residential
        }
        if recipient_address[:street2]
          recipient_address_hash[:StreetLines] = [recipient_address[:street], recipient_address[:street2]]
        end
      
        # Create the driver
        driver = create_driver(:ship)
      
      
        @params = {
        
          :WebAuthenticationDetail => {
            :UserCredential => {
              :Key                          => @auth_key,
              :Password                     => @auth_password
            }                         
          },                               
          :ClientDetail => {               
            :AccountNumber                  => @account_number,
            :MeterNumber                    => @meter_number
          },                               
          :Version => {                    
            :ServiceId                      => WS_VERSION[:ship][:service],
            :Major                          => WS_VERSION[:ship][:major],
            :Intermediate                   => WS_VERSION[:ship][:intermediate],
            :Minor                          => WS_VERSION[:ship][:minor]
          },
          :RequestedShipment => {          
            :ShipTimestamp                  => time,
            :DropoffType                    => @dropoff_type,
            :ServiceType                    => service_type,
            :PackagingType                  => @packaging_type,
            :PreferredCurrency              => @currency,
            :Shipper => {
              :Contact  => {
                :PersonName                 => shipper_contact[:name],
                :PhoneNumber                => shipper_contact[:phone_number]
              },
              :Address  => {
                :CountryCode                => shipper_address[:country],
                :StreetLines                => shipper_address[:street],
                :City                       => shipper_address[:city],
                :StateOrProvinceCode        => shipper_address[:state],
                :PostalCode                 => shipper_address[:zip]
              }
            },
            :Recipient  => {
              :Contact  => recipient_contact_hash,
              :Address  => recipient_address_hash
            },
            :Origin => {},
            :ShippingChargesPayment  => {
              :PaymentType                  => @payment,
              :Payor => {
                :AccountNumber              => @account_number,
                :CountryCode                => shipper_address[:country]
              }
            },
            :LabelSpecification => {
              :LabelFormatType              => @label_type,
              :ImageType                    => @label_image_type
            },
            :RateRequestTypes               => @rate_request_type,
            :RequestedPackages  => [{
                :Weight => {
                  :Units                    => @units, 
                  :Value                    => weight
                },
                :Dimensions => {
                  :Length                   => length,
                  :Width                    => width,
                  :Height                   => height,
                  :Units                    => @size_units
                },
                :CustomerReferences => [{
                  :CustomerReferenceType => 'CUSTOMER_REFERENCE',
                  :Value => reference_number
                }]
            }]
          }
        
        } #end prams
      
      
      
      
      
        result = driver.processShipment(@params)
      
        successful = successful?(result)
      
        if successful
          pre = result.completedShipmentDetail.shipmentRating.shipmentRateDetails

          #discount_rate = ((pre.class == Array ? pre[0].totalNetCharge.amount.to_f : pre.totalNetCharge.amount.to_f) * 100).to_i
        
          total_base_charge = ((pre.class == Array ? pre[0].totalBaseCharge.amount.to_f : pre.totalBaseCharge.amount.to_f) * 100).to_i
          total_surcharges = ((pre.class == Array ? pre[0].totalSurcharges.amount.to_f : pre.totalSurcharges.amount.to_f) * 100).to_i
          total_taxes = ((pre.class == Array ? pre[0].totalTaxes.amount.to_f : pre.totalTaxes.amount.to_f) * 100).to_i
        
          #adj_discount_rate = discount_rate + total_surcharges + total_taxes
        
          list_rate = total_base_charge + total_surcharges + total_taxes

          label = Tempfile.new("shipping_label")
          label.write Base64.decode64(result.completedShipmentDetail.completedPackageDetails.label.parts.image)
          label.rewind
        
          tracking_number = result.completedShipmentDetail.completedPackageDetails.trackingId.trackingNumber
        
          #[adj_discount_rate, label, tracking_number]
          [list_rate, label, tracking_number]
        else
          dispatch_error(result)
        end
    
      end #end method label
    
    
    
    
      # Cancel a shipment
      #
      #  fedex = Fedex::Base.new(options)
      #  result = fedex.cancel(fields)
      #
      # Returns a boolean indicating whether or not the operation was successful
      #
      # === Required options for cancel
      #   :tracking_number - The Fedex-provided tracking number you wish to cancel
      #
      # === Optional options for cancel
      #   :carrier_code    - The four-letter abbreviation for the Fedex service used for the shipment to be canceled.
      #                      Plugin handles Ground and Express shipments automatically based on tracking number length.
      def cancel(options = {})
      
        check_required_options(:ship_cancel, options)
      
        tracking_number = options[:tracking_number]
        carrier_code    = options[:carrier_code] || carrier_code_for_tracking_number(tracking_number)
      
        time = Time.now #you can cancel at any time
      
        @params = {

           :WebAuthenticationDetail => {
             :UserCredential => {
               :Key                          => @auth_key,
               :Password                     => @auth_password
             }                         
           },                               
           :ClientDetail => {               
             :AccountNumber                  => @account_number,
             :MeterNumber                    => @meter_number
           },                               
           :Version => {                    
             :ServiceId                      => WS_VERSION[:ship][:service],
             :Major                          => WS_VERSION[:ship][:major],
             :Intermediate                   => WS_VERSION[:ship][:intermediate],
             :Minor                          => WS_VERSION[:ship][:minor]
           },
           :ShipTimestamp                    => time,
           :TrackingNumber                   => tracking_number
    
        } #end prams
      
        driver = create_driver(:ship)
        result = driver.deleteShipment(@params)
      
        return successful?(result)
    
      end #end method cancel
    
    
    
  
  private

      def dispatch_error(result)
      
        raise FedexError.new("#{get_error(result)}\n\n#{clean_print(@params)}")

      end #end method dispatch_error(result)
    
    
      def clean_print(params)
      
        @error_output = ""
      
        traverse(params)
      
        @error_output
      end #end method clean_print(params)
    
    

      def traverse( aHash, level = 0 )

        aHash.each do |k, v|

          separator = ""
          0.upto(level) {|i| separator += "     "}
          @error_output += separator

          if v.kind_of?(Hash)
             @error_output += "#{k} => \n"
             traverse(v, level + 1)
          elsif v.kind_of?(Array)
             @error_output += "#{k} => \n"
             v.each {|e| traverse(e, level + 1)}
          else
            @error_output += "#{k} => #{v}\n"
          end

        end # do

      end # def traverse

    
    
      # Checks the supplied options for a given method or field and throws an exception if anything is missing
      def check_required_options(option_set_name, options = {})
        required_options = REQUIRED_OPTIONS[option_set_name]
        missing = []
        required_options.each{|option| missing << option if options[option].nil?}
      
        unless missing.empty?
          raise MissingInformationError.new("Missing #{missing.collect{|m| ":#{m}"}.join(', ')}")
        end
    
      end #end method check_required_options
    
    
    
      # Creates and returns a driver for the requested action
      def create_driver(name)
        path = File.expand_path(DIR + '/' + WSDL_PATHS[name])
        wsdl = SOAP::WSDLDriverFactory.new(path)
        driver = wsdl.create_rpc_driver
        driver.options["protocol.http.ssl_config.verify_mode"] = OpenSSL::SSL::VERIFY_NONE
        driver.generate_explicit_type = true
        driver.wiredump_dev = STDOUT if @debug
      
        driver
    
      end #end method create_driver
    
    
    
      # Resolves the ground+residential discrepancy.  If a package is shipped via Fedex Ground to an address marked as residential the service type
      # must be set to ServiceTypes::GROUND_HOME_DELIVERY and not ServiceTypes::FEDEX_GROUND.
      def resolve_service_type(service_type, residential)
      
        if residential && (service_type == ServiceTypes::FEDEX_GROUND)
          ServiceTypes::GROUND_HOME_DELIVERY
        else
          service_type
        end
    
      end #end method resolve_service_type
    
    
    
      # Returns a boolean determining whether a request was successful.
      def successful?(result)
      
        if defined?(result.cancelPackageReply)
          SUCCESSFUL_RESPONSES.detect{|r| r == result.cancelPackageReply.highestSeverity} ? true : false
        else
          SUCCESSFUL_RESPONSES.detect{|r| r == result.highestSeverity} ? true : false
        end
      
      end #end method successful?
    
    
    
      #returns a clean error string from a soap response
      def get_error(result)
      

        if defined? result.notifications.first.code
  			  code = result.notifications.first.code 
  		  elsif defined? result.notifications.code
  		    code = result.notifications.code
  		  else
  		    code = ''
  	    end
	    
  	    if defined? result.notifications.first.message
  			  message = result.notifications.first.message
  		  elsif defined? result.notifications.message
  		    message = result.notifications.message
  		  else
  		    message = ''
  	    end

  			return "Fedex Error #{code}: #{message}"
			
  		end #end method get_error
    
    
    
      # Attempts to determine the carrier code for a tracking number based upon its length.  Currently supports Fedex Ground and Fedex Express
      def carrier_code_for_tracking_number(tracking_number)
      
        case tracking_number.length
        when 12
          'FDXE'
        when 15
          'FDXG'
        end
    
      end #end method carrier_code_for_tracking_number
  
  
      # Gets a timestamp for the shippment, automatically taking account shippments on saturday, sunday or holidays.
      # if one of these days is encountered the next business day in the future is returned.
      def get_ship_timestamp
      
        now = Time.now
      
        #alter date if date is a saturday or sunday using "wday" 0=Sun, 6=Sat
        if now.wday == 6
          now += 48*60*60 #saturday, add two days to get to monday
        elsif now.wday == 0
          now += 24*60*60 #sunday, add one day to get to monday
        end
      
        # at this point we shouldn't be on a weekend day, but the day could be 
        # a holiday, so lets check that.

        #calculate memorial day - last monday in may
        memorial_day = Time.local(now.year, 5, 31, 0, 0, 0)
        wday = memorial_day.wday
        while wday != 1
          memorial_day -= 24*60*60
          wday = memorial_day.wday
        end

        #calculate independence day - July 4th
        independence_day = Time.local(now.year, 7, 4, 0, 0, 0)
      
        #calculate labor day - 1st monday in september
        labor_day = Time.local(now.year, 9, 1, 0, 0, 0)
        wday = labor_day.wday
        while wday != 1
          labor_day += 24*60*60
          wday = labor_day.wday
        end

        #calculate thanksgiving day - last thursday in november
        thanksgiving_day = Time.local(now.year, 11, 30, 0, 0, 0)
        wday = thanksgiving_day.wday
        while wday != 4
          thanksgiving_day -= 24*60*60
          wday = thanksgiving_day.wday
        end
      
        #calculate christmas
        christmas_day = Time.local(now.year, 12, 25, 0, 0, 0)
      
        #calculate newyears
        new_years_day = Time.local(now.year, 1, 1, 0, 0, 0)
      
        #alter date if date is a holiday
        if now.year == memorial_day.year && now.month == memorial_day.month && now.day == memorial_day.day
          now += 24*60*60
        elsif now.year == independence_day.year && now.month == independence_day.month && now.day == independence_day.day
          now += 24*60*60
        elsif now.year == labor_day.year && now.month == labor_day.month && now.day == labor_day.day
          now += 24*60*60
        elsif now.year == thanksgiving_day.year && now.month == thanksgiving_day.month && now.day == thanksgiving_day.day
          now += 24*60*60
        elsif now.year == christmas_day.year && now.month == christmas_day.month && now.day == christmas_day.day
          now += 24*60*60
        elsif now.year == new_years_day.year && now.month == new_years_day.month && now.day == new_years_day.day
          now += 24*60*60
        end
      
      
        return now
      
      end #end method get_ship_timestamp
  
  
    end #end class Base
  
  
  
    # The following modules were created by running wsdl2ruby.rb on the various WSDLs and pulling out the appropriate data.
    # These are provided primarily for convenience.
    module ServiceTypes
      EUROPE_FIRST_INTERNATIONAL_PRIORITY   = "EUROPE_FIRST_INTERNATIONAL_PRIORITY"
      FEDEX_1_DAY_FREIGHT                   = "FEDEX_1_DAY_FREIGHT"
      FEDEX_2_DAY                           = "FEDEX_2_DAY"
      FEDEX_2_DAY_FREIGHT                   = "FEDEX_2_DAY_FREIGHT"
      FEDEX_3_DAY_FREIGHT                   = "FEDEX_3_DAY_FREIGHT"
      FEDEX_EXPRESS_SAVER                   = "FEDEX_EXPRESS_SAVER"
      FEDEX_GROUND                          = "FEDEX_GROUND"
      FIRST_OVERNIGHT                       = "FIRST_OVERNIGHT"
      GROUND_HOME_DELIVERY                  = "GROUND_HOME_DELIVERY"
      INTERNATIONAL_DISTRIBUTION_FREIGHT    = "INTERNATIONAL_DISTRIBUTION_FREIGHT"
      INTERNATIONAL_ECONOMY                 = "INTERNATIONAL_ECONOMY"
      INTERNATIONAL_ECONOMY_DISTRIBUTION    = "INTERNATIONAL_ECONOMY_DISTRIBUTION"
      INTERNATIONAL_ECONOMY_FREIGHT         = "INTERNATIONAL_ECONOMY_FREIGHT"
      INTERNATIONAL_FIRST                   = "INTERNATIONAL_FIRST"
      INTERNATIONAL_PRIORITY                = "INTERNATIONAL_PRIORITY"
      INTERNATIONAL_PRIORITY_DISTRIBUTION   = "INTERNATIONAL_PRIORITY_DISTRIBUTION"
      INTERNATIONAL_PRIORITY_FREIGHT        = "INTERNATIONAL_PRIORITY_FREIGHT"
      PRIORITY_OVERNIGHT                    = "PRIORITY_OVERNIGHT"
      STANDARD_OVERNIGHT                    = "STANDARD_OVERNIGHT"
    end
  
    module PackagingTypes
      FEDEX_10KG_BOX                        = "FEDEX_10KG_BOX"
      FEDEX_25KG_BOX                        = "FEDEX_25KG_BOX"
      FEDEX_BOX                             = "FEDEX_BOX"
      FEDEX_ENVELOPE                        = "FEDEX_ENVELOPE"
      FEDEX_PAK                             = "FEDEX_PAK"
      FEDEX_TUBE                            = "FEDEX_TUBE"
      YOUR_PACKAGING                        = "YOUR_PACKAGING"
    end
    
    module DropoffTypes
      BUSINESS_SERVICE_CENTER               = "BUSINESS_SERVICE_CENTER"
      DROP_BOX                              = "DROP_BOX"
      REGULAR_PICKUP                        = "REGULAR_PICKUP"
      REQUEST_COURIER                       = "REQUEST_COURIER"
      STATION                               = "STATION"
    end
  
    module PaymentTypes
      RECIPIENT                             = "RECIPIENT"
      SENDER                                = "SENDER"
      THIRD_PARTY                           = "THIRD_PARTY"
    end
  
    module RateRequestTypes
      ACCOUNT                               = "ACCOUNT"
      LIST                                  = "LIST"
    end
  
    module WeightUnits
      KG                                    = "KG"
      LB                                    = "LB"
    end
  
    module LinearUnits
      CM                                    = "CM"
      IN                                    = "IN"
    end
  
    module CurrencyTypes
      USD                                   = "USD"
    end
  
    module LabelFormatTypes
      COMMON2D                              = "COMMON2D"
      LABEL_DATA_ONLY                       = "LABEL_DATA_ONLY"
    end
  
    module LabelSpecificationImageTypes
      DPL                                   = "DPL"
      EPL2                                  = "EPL2"
      PDF                                   = "PDF"
      PNG                                   = "PNG"
      ZPLII                                 = "ZPLII"
    end
  
    module LabelStockTypes
      PAPER_4X6                             = "PAPER_4X6"
      PAPER_7X475                           = "PAPER_7X475"
      STOCK_4X6                             = "STOCK_4X6"
      STOCK_4X675_LEADING_DOC_TAB           = "STOCK_4X675_LEADING_DOC_TAB"
      STOCK_4X8                             = "STOCK_4X8"
      STOCK_4X9_LEADING_DOC_TAB             = "STOCK_4X9_LEADING_DOC_TAB"
    end
  end #end Fedex Module