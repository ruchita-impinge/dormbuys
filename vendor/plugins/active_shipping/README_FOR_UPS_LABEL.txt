UPS label generation is a two step process

1. Shipment Confirm Request/Response
2. Shipment Accept Request/Response

The Shipment Confirm Request consists of origin, destination, packages information, user account info and specification for label.
For valid Shipment Confirm Request, UPS returns a Shipment Confirm Response which contains the shipment charges information and Shipment Digest.

The Shipment Digest is further send with the Shipment Accept Request (which means that the user is finally placing the shipment order and will get the UPS label for his shipment).

For valid Shipment Accept request, UPS returns the shipment identification number, tracking number and the label image.

======================================How to Use===========================================

## Shipment Confirm Request

require 'active_shipping'

include ActiveMerchant::Shipping

#create the packages
#please refer Package class (lib/shipping/package.rb) for more info

#packages with no insured value
packages = [Package.new(100, [93, 10], :cylinder => true), Package.new((7.5 * 16),[15, 10, 4.5], :units => :imperial)]

#package with high value(more than $999, for high value report)
packages = [Package.new(100, [93, 10], :cylinder => true, :value => 1000, :currency => "USD")]


#specify the ups service
#refer ups.rb for more services and their code

carrier_service = "14"

#label specification

label_specification = {:print_code => "GIF", :format_code => "GIF", :user_agent => "Mozilla/4.5"}

#create a options hash containing origin, destination. For test environment pass :test => true

options = {:origin => {:address_line1 => "12 W. Maple Street", :address_line2 => "4th Floor", :country => 'US', :state => 'IL',:city => 'Chicago',:zip => '60610', :phone => "(312) 266-9642", :name => "Brian Webb", :attention_name => "Webb", :origin_number => "A64V28"}, :destination => {:company_name => "parker smith company", :attention_name => "parker smith", :phone => "(212) 210-2100", :address_line1 => "450 W.", :address_line2 => "33 Street", :country => 'US', :state => 'NY', :city => 'New York', :zip => '10001'}, :test => true}

#make a ups instance with your userid, password and access key
ups = UPS.new(:login => 'dormbuysdotcom', :password => 'xavier01', :key => '9C60A235E9C53978', :test => true)

#send the Shipment Confirm Request and catch the response. if successful then it will return an identification number, shipment charges and a shipment digest.

confirm_response = ups.shipment_confirmation_request(carrier_service, packages, label_specification, options)

#send the Shipment Accept Request and catch the response. if successful then it will return tracking number, base64 html label, base64 graphic label for each package and identification number for the shipment.

accept_response = ups.shipment_accept_request(confirm_response.digest, {:test => true})

#To get label and other info of each package of the above shipment

accept_response.shipment_packages.each do |package|
	html_image = package.html_image #gives you the base64 code for html label
	graphic_image = package.graphic_image #gives you the base64 code for graphic label
	label_image_format = package.label_image_format #gives you the images format(gif/png)
	tracking_number = package.tracking_number #gives you the tracking number of package
end

#Use following to get "high value report" (if user has requested insurance value more than $999 for a package)

	accept_response.high_value_report_image              #gives you the base64 code for receipt
	accept_response.high_value_report_image_format       #gives you the format(default is "html")

#########################################Void Shipment########################################

Method => void_shipment(identification_number, tracking_numbers, options)

#identification_number is the identification number of shipment

#tracking_numbers is an array of tracking numbers of the packages, user want to void. It should be passed only if user wants to void a shipment partially.

#we can pass {:test => true} into options for test environment

1. For voiding entire shipment
	
	identification_number = "1Z12345E0193081456" #identification number of shipment
	
	ups.void_shipment(identification_number, [], {:test => true})

2. For voiding some packages of a shipment
	identification_number = "1Z12345E2318693258"
	tracking_numbers = ["1Z12345E0193072168"]
	
	ups.void_shipment(identification_number, tracking_numbers, {:test => true})