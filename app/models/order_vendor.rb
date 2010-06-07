class OrderVendor < ActiveRecord::Base
  
  DORMBUYS = 1
  
  has_many :orders
  
  belongs_to :state
  belongs_to :country
  
  validates_presence_of :name, :address, :city, :state_id, :zip_code, :country_id,
    :customer_service_phone, :customer_service_email

  has_attached_file :logo, 
    :styles => {
      :large => "200x125>"
    },
    :default_style => :large,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":class/:attachment/:id/:style_:basename.:extension"
    #:url => "/content/images/:class/:attachment/:id/:style_:basename.:extension",
    #:path => ":rails_root/public/content/images/:class/:attachment/:id/:style_:basename.:extension"

  validates_attachment_presence :logo
  validates_attachment_content_type :logo, 
    :content_type => ['image/pjpeg', 'image/jpeg', 'image/jpg', 'image/gif', 'image/png']
  validates_attachment_size :logo, 
    :less_than => 1.megabytes, :message => "can't be more than 1MB"
  
end
