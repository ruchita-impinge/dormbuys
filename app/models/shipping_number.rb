class ShippingNumber < ActiveRecord::Base
  
  before_save :check_del_num
  
  belongs_to :courier
  belongs_to :order_line_item

  FEDEX_TRACKING_URL = "http://www.fedex.com/Tracking?tracknumbers=#TRACKINGNUMBER#&language=english&action=track&cntry_code=us"
  UPS_TRACKING_URL = "http://wwwapps.ups.com/WebTracking/processInputRequest?sort_by=status&tracknums_displayed=1&TypeOfInquiryNumber=T&loc=en_US&InquiryNumber1=#TRACKINGNUMBER#&track.x=0&track.y=0"
  USPS_TRACKING_URL = "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?origTrackNum=#TRACKINGNUMBER#"
  #DHL_TRACKING_URL =  "http://track.dhl-usa.com/TrackByNbr.asp?ShipmentNumber=#TRACKINGNUMBER#"
  DHL_TRACKING_URL = "http://webtrack.dhlglobalmail.com/?trackingnumber=#TRACKINGNUMBER#+"
  CANADA_POST_TRACKING_URL = "https://em.canadapost.ca/emo/basicPin.do?trackingId=#TRACKINGNUMBER#&trackingCode=PIN&action=query&language=en&scloc=segment"

  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end #end method should_destroy?
  
  
  def tracking_url
    case self.courier_id
      when Courier::FEDEX
        FEDEX_TRACKING_URL.gsub(/#TRACKINGNUMBER#/, self.tracking_number)
      when Courier::UPS
        UPS_TRACKING_URL.gsub(/#TRACKINGNUMBER#/, self.tracking_number)
      when Courier::USPS
        USPS_TRACKING_URL.gsub(/#TRACKINGNUMBER#/, self.tracking_number)
      when Courier::DHL
        DHL_TRACKING_URL.gsub(/#TRACKINGNUMBER#/, self.tracking_number)
      when Courier::CANADA_POST
        CANADA_POST_TRACKING_URL.gsub(/#TRACKINGNUMBER#/, self.tracking_number)
    end
  end #end method tracking_url



  def check_del_num
    if self.tracking_number == "delete"
      self.tracking_number = ""
      self.courier_id = ""
    end
  end #end method check_del_num


  
end
