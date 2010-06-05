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

packages = [Package.new(100, [93, 10], :cylinder => true), Package.new((7.5 * 16),[15, 10, 4.5], :units => :imperial)]

#specify the ups service
#refer ups.rb for more services and their code

carrier_service = "14"

#label specification

label_specification = {:print_code => "GIF", :format_code => "GIF", :user_agent => "Mozilla/4.5"}

#create a options hash containing origin, destination. For test environment pass :test => true

options = {:origin => {:address_line1 => "12 W. Maple Street", :address_line2 => "4th Floor", :country => 'US', :state => 'IL',:city => 'Chicago',:zip => '60610', :phone => "(312) 266-9642", :name => "Brian Webb", :attention_name => "Webb", :origin_number => "A64V28"}, :destination => {:company_name => "XYZ company", :attention_name => "xyz company", :phone => "(212) 210-2100", :address_line1 => "450 W.", :address_line2 => "33 Street", :country => 'US', :state => 'NY', :city => 'New York', :zip => '10001'}, :test => true}

#make a ups instance with your userid, password and access key
ups = UPS.new(:login => 'dormbuysdotcom', :password => 'xavier01', :key => '9C60A235E9C53978')

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
