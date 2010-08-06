require 'digest/sha1'

class User < ActiveRecord::Base
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  cattr_accessor :current_user
  
  before_create :setup_roles, :add_to_mailing_list
  before_validation :set_shipping_address
    
  
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :vendors
  has_many :orders
  has_many :gift_registries
  has_many :wish_lists
  has_many :addresses
  has_many :carts
  belongs_to :billing_state, :class_name => "State", :foreign_key => "billing_state_id"
  belongs_to :shipping_state, :class_name => "State", :foreign_key => "shipping_state_id"
  belongs_to :billing_country, :class_name => "Country", :foreign_key => "billing_country_id"
  belongs_to :shipping_country, :class_name => "Country", :foreign_key => "shipping_country_id"

 
  validates_format_of       :first_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :first_name,     :maximum => 100
  
  validates_format_of       :last_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :last_name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message


  attr_accessible :email, :first_name, :last_name, :phone, :password, :password_confirmation,
   :whoami,
   :billing_phone,
   :dorm_ship_not_part,
   :dorm_ship_not_assigned,
   :dorm_ship_college_name,
   :shipping_phone,
   :shipping_country_id,
   :shipping_zipcode,
   :shipping_state_id,
   :shipping_city,
   :shipping_address2,
   :shipping_address,
   :shipping_last_name,
   :shipping_first_name,
   :billing_country_id,
   :billing_zipcode,
   :billing_state_id,
   :billing_city,
   :billing_address2,
   :billing_address,
   :billing_last_name,
   :billing_first_name,
   :user_profile_type_id
  
  
  
   def set_shipping_address

     case self.user_profile_type_id

       when Order::ADDRESS_SAME
         self.shipping_first_name  = self.billing_first_name
         self.shipping_last_name   = self.billing_last_name
         self.shipping_address     = self.billing_address
         self.shipping_address2    = self.billing_address2
         self.shipping_city        = self.billing_city
         self.shipping_state_id    = self.billing_state_id
         self.shipping_zipcode     = self.billing_zipcode
         self.shipping_country_id  = self.billing_country_id
         self.shipping_phone       = self.billing_phone
       when Order::ADDRESS_DIFFERENT
         # use form vars
       when Order::ADDRESS_DORM
         # use form vars
     end #end case statement

   end #end method set_shipping_address
   
  def has_role?(role_in_question)
    @_list ||= self.roles.collect(&:name)
    return true if @_list.include?("admin")
    (@_list.include?(role_in_question.to_s) )
  end
  
  
  def is_admin?
    self.has_role?("admin")
  end #end method is_admin?


  def setup_roles
    if self.role_ids.empty?
      self.role_ids = [1] #default customer role
    end
  end #end method setup_roles
  
  
  def add_to_mailing_list
    mail_client = EmailListClient.find_by_email(self.email)
    unless mail_client
      EmailListClient.create(:email => self.email)
    end
  end #end method add_to_mailing_list


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_by_email(email.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  
  def wish_list
    
    if self.wish_lists.empty?
      wl = self.wish_lists.create()
      return wl
    else
      return self.wish_lists.first
    end
    
  end #end method wish_list
  
  
  
  ##
  # method to reset the user's password, and send them an email telling
  # them what the reset password is
  ##
  def send_new_password
  
    #get a random string
    new_pass = User.random_string(10)
    
    #set the password & confirmation 
    self.password = self.password_confirmation = new_pass
    
    #save the new password thereby encrypting and setting the
    #crypted_password
    self.save
    
    #send an email to let the user know
    Notifier.send_later(:deliver_forgot_password, self.email, new_pass)
  
  end #end send_new_password
  
  
  
  def dorm_shipping_address2=(ds_addy2)
    self.shipping_address2 = ds_addy2
  end #end method dorm_shipping_address2
  
  def dorm_shipping_address2
    self.shipping_address2
  end #end method dorm_shipping_address2
  
  

  protected
    
  ##
  # method to generate a random string of charactares consisting of 
  # lowercase, uppercase, and numbers that is as long as the specified 
  # length
  #
  # @param Integer len - length of random string
  # @return - alpha numeric string of the specified length
  ##
  def self.random_string(len)

    #array holding a-z + A-Z + 0-9
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a

    newpass = ""

    #loop upto the specified length adding a random character
    #from the chars array to the new pass
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }

    return newpass

  end #end self.random_string


end
