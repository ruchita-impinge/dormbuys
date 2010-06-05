require 'base64'
require 'fileutils'
require 'tempfile'
require 'active_shipping'

class UpsLabelTest
  
  include ActiveMerchant::Shipping
  
  UPS_ORIGIN_NUMBER = "A64V28"
  UPS_LOGIN = 'dormbuysdotcom'
  UPS_PASSWORD = 'xavier01'
  UPS_KEY = '9C60A235E9C53978'
  
  TESTING = true
  SAVE_LABEL_LOCATION = "/Users/brian/Desktop/db_ups_labels"
  
    # services located in UPS::DEFAULT_SERVICES
    #
    # "01" => "UPS Next Day Air",
    # "02" => "UPS Second Day Air",
    # "03" => "UPS Ground",
    # "07" => "UPS Worldwide Express",
    # "08" => "UPS Worldwide Expedited",
    # "11" => "UPS Standard",
    # "12" => "UPS Three-Day Select",
    # "13" => "UPS Next Day Air Saver",
    # "14" => "UPS Next Day Air Early A.M.",
    # "54" => "UPS Worldwide Express Plus",
    # "59" => "UPS Second Day Air A.M.",
    # "65" => "UPS Saver",
    # "82" => "UPS Today Standard",
    # "83" => "UPS Today Dedicated Courier",
    # "84" => "UPS Today Intercity",
    # "85" => "UPS Today Express",
    # "86" => "UPS Today Express Saver"
  
  
  def initialize
    @ups = UPS.new(:login => UPS_LOGIN, :password => UPS_PASSWORD, :key => UPS_KEY)
  end #end method initialize
  
  
  def run_tests
    #UPS::DEFAULT_SERVICES.keys.sort.each do |code|
    ["03"].each do |code|
      begin
        trk_num =  run_test_for_service(code)
        puts "Generated label for: #{UPS::DEFAULT_SERVICES[code]} => #{trk_num}"
      rescue => e
        puts "ERROR GENERATING: #{UPS::DEFAULT_SERVICES[code]} => #{e.message}"
      end
    end
  end #end method run_tests
  
  
  def get_packages
    #please refer Package class (lib/shipping/package.rb) for more info
    [
      Package.new((3 * 16),[12, 12, 12], :units => :imperial)
    ]
  end #end method get_packages
  
  
  def get_label_specification
    # Label print method code that the labels are to be generated for EPL2 formatted 
    # labels use EPL, for SPL formatted labels use SPL, for ZPL formatted labels use ZPL, 
    # for STAR printer formatted labels use STARPL and for image formats use GIF.
    
    {:print_code => "GIF", :format_code => "GIF", :user_agent => "Mozilla/4.5"}
  end #end method label_specification
  
  
  def get_options
    #create a options hash containing origin, destination. For test environment pass :test => true
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
        :origin_number => UPS_ORIGIN_NUMBER
      }, 
      :destination => {
        :company_name => "Brian Webb",
        :attention_name => "Brian Webb",
        :phone => "(502) 298-7961", 
        :address_line1 => "1207 Downhill Run", 
        #:address_line2 => "", 
        :country => 'US', 
        :state => 'KY', 
        :city => 'Goshen', 
        :zip => '40026'
        }, 
      :test => TESTING
    }

  end #end method get_options
  
  
  def create_confirm_response(carrier_service, packages, label_specification, options)
    #send the Shipment Confirm Request and catch the response. if successful then it will return an identification number, shipment charges and a shipment digest.
    @confirm_response = @ups.shipment_confirmation_request(carrier_service, packages, label_specification, options)
  end #end method create_confirm_response
  
  
  def create_shipment_request(confirm_response)
    #send the Shipment Accept Request and catch the response. if successful then it will return tracking number, base64 html label, base64 graphic label for each package and identification number for the shipment.
    @accept_response = @ups.shipment_accept_request(confirm_response.digest, {:test => TESTING})
  end #end method create_shipment_request(confirm_response)
  
  
  
  
  def run_test_for_service(carrier_service)
    
    packages = get_packages
    
    label_specification = get_label_specification
  
    options = get_options

    confirm_response = create_confirm_response(carrier_service, packages, label_specification, options)

    accept_response = create_shipment_request(confirm_response)

    out = []

    #To get label and other info of each package of the above shipment
    accept_response.shipment_packages.each do |package|
      
      #gives you the base64 code for html label
    	html_image = package.html_image 
    	
    	#gives you the base64 code for graphic label
    	graphic_image = package.graphic_image 
    	
    	#gives you the images format(gif/png)
    	label_image_format = package.label_image_format 
    	
    	#gives you the tracking number of package
    	tracking_number = package.tracking_number 
    	
    	
    	#write out the file
    	label_tmp_file = Tempfile.new("shipping_label")
      label_tmp_file.write Base64.decode64(graphic_image)
      label_tmp_file.rewind
      
      filename = "#{SAVE_LABEL_LOCATION}/#{tracking_number}.#{label_image_format.downcase}"
      f = File.new(filename, "wb")
      f.write File.new(label_tmp_file.path).read
      f.close
 
    	out << tracking_number
    	
    end #end shipment_packages.each
    
    return out
  end #end run_test_for_service
  
   
  
  
end #end class