require "digest/sha1"

class Cart < ActiveRecord::Base
  
  attr_accessor :should_validate, :gc_errors, :credit_card, :cc_billing_address, :skip_credit_card
  
  after_update :save_cart_items
  before_validation :set_shipping_address
  
  has_many :cart_items, :dependent => :destroy
  has_and_belongs_to_many :gift_cards
  belongs_to :coupon
  belongs_to :user
  belongs_to :billing_state, :class_name => "State", :foreign_key => "billing_state_id"
  belongs_to :shipping_state, :class_name => "State", :foreign_key => "shipping_state_id"
  belongs_to :billing_country, :class_name => "Country", :foreign_key => "billing_country_id"
  belongs_to :shipping_country, :class_name => "Country", :foreign_key => "shipping_country_id"
  
  
  validates_presence_of :user_profile_type_id, :billing_first_name, :billing_last_name, :billing_address, :billing_city, 
    :billing_state_id, :billing_zipcode, :billing_country_id, :shipping_first_name, :shipping_last_name, :shipping_address, 
    :shipping_city, :shipping_state_id, :shipping_zipcode, :shipping_country_id, :shipping_phone, :how_heard_option_id,
    :email, :billing_phone, :if => :should_validate?
    
  validates_format_of :billing_phone, :with => /^[0-9]{3,3}-[0-9]{3,3}-[0-9]{4,4}$/,
      :message => "Phone number is not valid (xxx-xxx-xxxx).", :if => :should_validate?
      
  validates_format_of :shipping_phone, :with => /^[0-9]{3,3}-[0-9]{3,3}-[0-9]{4,4}$/,
      :message => "Phone number is not valid (xxx-xxx-xxxx).", :if => :should_validate?
  
  validates_presence_of :how_heard_option_value, :message => "please let us know where you heard about Dormbuys", 
    :if => :how_heard_other_required?

  validates_presence_of :whoami, :message => "current status is required", :if => :should_validate?
    
  
 
  def items
    self.cart_items.find(:all, :conditions => {:is_gift_registry_item => false, :is_wish_list_item => false})
  end #end method items
  
  
  def wish_list_items
    self.cart_items.find(:all, :conditions => {:is_wish_list_item => true})
  end #end method wish_list_items
  
  
  def gift_registry_items
    self.cart_items.find(:all, :conditions => {:is_gift_registry_item => true})
  end #end method gift_registry_items
  
  

  def validate
    unless self.gc_errors.blank?
      self.gc_errors.each do |gc_err|
        self.errors.add_to_base(gc_err)
      end
    end
    
    if should_validate?
      if self.grand_total.cents > 0
        setup_cc_attributes
        unless self.credit_card.blank?
          unless self.credit_card.valid?
            self.credit_card.errors.full_messages.each{|e| self.errors.add_to_base("Credit Card #{e}")}
          end
        end
      end
    end
    
  end #end method validate
  
  
  def shipping_phone=(_sphone)
    return if _sphone.blank?
    s_phone = _sphone.gsub(/[^0-9]/, "").gsub(/^([0-9]{0,3})([0-9]{0,3})([0-9]{0,})$/) do |match|
      tmp = ""
      tmp += $1 if $1.size > 0
      tmp += "-" + $2 if $2.size > 0
      tmp += "-" + $3 if $3.size > 0
      tmp
    end
    write_attribute(:shipping_phone, s_phone)
  end  
  
  
  def billing_phone=(_bphone)
    return if _bphone.blank?
    b_phone = _bphone.gsub(/[^0-9]/, "").gsub(/^([0-9]{0,3})([0-9]{0,3})([0-9]{0,})$/) do |match|
      tmp = ""
      tmp += $1 if $1.size > 0
      tmp += "-" + $2 if $2.size > 0
      tmp += "-" + $3 if $3.size > 0
      tmp
    end
    write_attribute(:billing_phone, b_phone)
  end
  
  
  def should_validate?
    self.should_validate.to_i == 1
  end #end method should_validate?
  
  
  def how_heard_other_required?
    should_validate? && Order::HOW_HEARD_INPUT_REQUIRED.include?(self.how_heard_option_id.to_i)
  end #end method how_heard_other_required?
  
  
  def dorm_ship_options_required?
    should_validate? && self.user_profile_type_id == Order::ADDRESS_DORM
  end #end method dorm_ship_options_required?
  
  
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
  
  
  def add(cart_item_attributes)
    
    begin
      variation = ProductVariation.find(cart_item_attributes[:variation_id])
      if cart_item_attributes[:qty].to_i > variation.qty_on_hand
        return [false, "Maximum available quantity of #{variation.full_title} is #{variation.qty_on_hand}, please call 1-866-502-DORM for special orders."]
      end
    rescue
      return [false, "Item could not be found, please call 1-866-502-DORM for help."]
    end
    
    item = self.cart_items.build
    item.quantity = cart_item_attributes[:qty]
    item.product_variation_id = cart_item_attributes[:variation_id]
    
    item.product_options = cart_item_attributes[:product_option_values].collect {|x| x['id']} unless cart_item_attributes[:product_option_values].blank?
    item.product_as_options = cart_item_attributes[:product_as_option_values].collect {|x| x['id']} unless cart_item_attributes[:product_as_option_values].blank?
    
    #these are items that a person wants to add to THEIR OWN registry / list
    item.is_gift_registry_item = cart_item_attributes[:is_gift_registry_item] unless cart_item_attributes[:is_gift_registry_item].blank?
    item.is_wish_list_item = cart_item_attributes[:is_wish_list_item] unless cart_item_attributes[:is_wish_list_item].blank?
    
    item.wish_list_item_id = cart_item_attributes[:wish_list_item_id] unless cart_item_attributes[:wish_list_item_id].blank?
    item.gift_registry_item_id = cart_item_attributes[:gift_registry_item_id] unless cart_item_attributes[:gift_registry_item_id].blank?
    
    item.save!
    
    return [true, ""]
    
  end #end method add(cart_item_attributes)
  
  
  def save_cart_items
    self.cart_items.each do |x|
      x.save(false)
    end
  end #end method save_cart_items
  
  
  
  def subtotal
    return Money.new(0) if self.cart_items.size == 0
    self.cart_items.collect(&:total_price).sum
  end #end method subtotal
  
  
  
  def tax
    return Money.new(0) if self.shipping_state_id.blank?
    
    if self.shipping_state_id == 18 #KY is 18
      
      taxable_total = Money.new(0)
      self.cart_items.each do |item|
        if item.product_variation.product.charge_tax
          taxable_total += item.total_price
        end
      end
      
      return (taxable_total * 0.06)
      
    else
      return Money.new(0)
    end
    
  end #end method tax
  
  
  
  def shipping

    if self.coupon && self.coupon.coupon_type_id == CouponType::FREE_SHIPPING
      if self.subtotal >= self.coupon.min_purchase
        return Money.new(0)
      end
    end
    
    shipping_calc_total = Money.new(0)
    self.cart_items.each do |item|
      if item.product_variation.product.charge_shipping
        shipping_calc_total += item.total_price
      end
    end
    
    table_rate = ShippingRatesTable.get_rate(shipping_calc_total)
    
    if self.shipping_state
      state_shipping = self.shipping_state.state_shipping_rates.collect(&:additional_cost).sum
      unless state_shipping.class == Money
        state_shipping = Money.new(0)
      end
    else
      state_shipping = Money.new(0)
    end
    
    return table_rate + state_shipping
    
  end #end method shipping
  
  
  
  def total_coupons
    return Money.new(0) unless self.coupon
    
    return Money.new(0) unless self.subtotal >= self.coupon.min_purchase
    
    
    if self.coupon.coupon_type_id == CouponType::FREE_SHIPPING
      
      return self.shipping
    
    elsif self.coupon.coupon_type_id == CouponType::DOLLAR
      
      return self.coupon.value
      
    elsif self.coupon.coupon_type_id == CouponType::PERCENTAGE
      
      return self.subtotal * (self.coupon.value / 100.0)
      
    elsif self.coupon.coupon_type_id == CouponType::TIERED_DOLLAR
      
      self.coupon.get_tiered_value(subtotal.to_s.to_f.ceil).to_money
      
    elsif self.coupon.coupon_type_id == CouponType::TIERED_PERCENTAGE
      
      return self.subtotal * (self.coupon.get_tiered_value(subtotal.to_s.to_f.ceil) / 100.0)
      
    end
    
  end #end method total_coupons
  
  
  
  def total_gift_cards
    return Money.new(0) unless self.gift_cards.size > 0
    
    total_gc = self.gift_cards.collect(&:current_amount).sum
    
    return total_gc >= total_before_gift_cards ? total_before_gift_cards : total_gc
    
  end #end method total_gift_cards
  
  
  def total_before_tax_and_gift_cards
    tmp = (subtotal + shipping) - (total_coupons)
    tmp.cents <= 0 ? Money.new(0) : tmp
  end #end method total_before_tax_and_gift_cards
  
  
  def total_before_gift_cards
    tmp = (subtotal + tax + shipping) - (total_coupons)
    tmp.cents <= 0 ? Money.new(0) : tmp
  end #end method total_before_gift_cards
  
  
  
  def grand_total
    tmp = (subtotal + tax + shipping) - (total_coupons + total_gift_cards)
    tmp.cents <= 0 ? Money.new(0) : tmp
  end #end method grand_total
  
  
  
  def recommended_products(count=1)
    actual_count = self.cart_items.last.product_variation.product.recommended_products.size
    count = actual_count if count > actual_count
    
    rec = []
    self.cart_items.last.product_variation.product.recommended_products.each do |rprod|
      rec << rprod
      break if rec.length == count
    end
    
    rec
    
  end #end method recommended_products
  
  
  def coupon_code
    self.coupon ? self.coupon.coupon_number : ""
  end #end method coupon_code
  
  
  def coupon_code=(code)
    c = Coupon.find_by_coupon_number(code)
    
    unless c
      self.errors.add(:coupon_code, "not found")
      return
    end
    
    if c.used == true && c.reusable == false
      self.errors.add(:coupon_code, 'already used')
      return
    end
    
    self.coupon = c
    
  end #end method coupon_code=(code)
  
  
  
  def gift_card_attributes=(gc_attributes)
    self.gc_errors = []
    return if gc_attributes[:giftcard_number].blank?
    
    card = GiftCard.find_by_giftcard_number(gc_attributes[:giftcard_number])
    
    if card
      if card.giftcard_pin == gc_attributes[:giftcard_pin]
        unless self.gift_cards.include? card
          self.gift_cards << card
        else
          self.gc_errors << "Gift Card is already added"
        end
      else
        self.gc_errors << "Invalid gift card pin"
      end
    else
      self.gc_errors << "Gift Card not found"
    end
  end #end method gift_card_attributes=(gc_attributes)
  
  
  def load_user_data(user)
    
    self.email                  = user.email
    self.whoami                 = user.whoami
    self.billing_phone          = user.billing_phone
    self.dorm_ship_not_part     = user.dorm_ship_not_part
    self.dorm_ship_not_assigned = user.dorm_ship_not_assigned
    self.dorm_ship_college_name = user.dorm_ship_college_name
    self.shipping_phone         = user.shipping_phone
    self.shipping_country_id    = user.shipping_country_id
    self.shipping_zipcode       = user.shipping_zipcode
    self.shipping_state_id      = user.shipping_state_id
    self.shipping_city          = user.shipping_city
    self.shipping_address2      = user.shipping_address2
    self.shipping_address       = user.shipping_address
    self.shipping_last_name     = user.shipping_last_name
    self.shipping_first_name    = user.shipping_first_name
    self.billing_country_id     = user.billing_country_id
    self.billing_zipcode        = user.billing_zipcode
    self.billing_state_id       = user.billing_state_id
    self.billing_city           = user.billing_city
    self.billing_address2       = user.billing_address2
    self.billing_address        = user.billing_address
    self.billing_last_name      = user.billing_last_name
    self.billing_first_name     = user.billing_first_name
    self.user_profile_type_id   = user.user_profile_type_id
    self.save(false)
    
  end #end method load_user_data(user)
  
  
  def display_payment_info
    setup_payment_display
  end #end method display_payment_info
  
  
  def order_payment
    payment_info
  end #end method order_payment
  
  
  def name_on_card
    payment_info['name_on_card'] rescue nil
  end #end method name_on_card
  
  def card_number
    payment_info['card_number'] rescue nil
  end #end method card_number
  
  def exp_date
    Date.parse(payment_info['exp_date']) rescue nil
  end #end method exp_date
  
  def card_type
    payment_info['card_type'] rescue nil
  end #end method card_type
  
  def vcode
    payment_info['vcode'] rescue nil
  end #end method vcode



  def credit_card_attributes=(attributes)
    unless attributes.first["card_number"].blank? || attributes.first["vcode"].blank?
      self.payment_info = attributes.first
    end
  end #end method credit_card_attributes=(credit_card_attributes)

  private
  
    def setup_payment_display
      setup_cc_attributes
      c = self.credit_card
      if c.blank?
        ["Error", "Error", "Error", "Error"]
      else
        [c.name, c.type, c.display_number, "#{c.month}/#{c.year}"]
      end
    end #end method setup_payment_display
  
  
    def setup_cc_attributes

      return if self.skip_credit_card == true
      
      cc_vals = payment_info
      return if cc_vals.blank?

      self.credit_card = Payment::PaymentManager.credit_card(
        cc_vals['card_type'], 
        cc_vals['card_number'], 
        Date.parse(cc_vals['exp_date']), 
        cc_vals['vcode'],
        cc_vals['name_on_card'].split(" ").first,
        cc_vals['name_on_card'].split(" ").last)


      self.cc_billing_address = Payment::PaymentManager.billing_address(
        :first_name => cc_vals['name_on_card'].split(" ").first,
        :last_name => cc_vals['name_on_card'].split(" ").last,
        :address1 => self.billing_address, 
        :address2 => self.billing_address2, 
        :city => self.billing_city, 
        :state => self.billing_state ? self.billing_state.abbreviation : "", 
        :zip => self.billing_zipcode, 
        :country => self.billing_country ? self.billing_country.abbreviation : ""
      )

    end #end method setup_cc_attributes


    def payment_info
      return nil if self.payment_data.blank? || self.salt.blank?
      de_crypt_str = Security::SecurityManager.decrypt_with_salt(self.payment_data, self.salt)
      name, number, exp_date, ctype, vcode = de_crypt_str.split("=!=")
      ex = Date.parse(exp_date)
      {
        'name_on_card' => name, 
        'card_number' => number,
        'exp_date' => exp_date,
        'expiration_date(1i)' => ex.year.to_s,
        'expiration_date(2i)' => ex.month.to_s,
        'expiration_date(3i)' => ex.day.to_s,
        'card_type' => ctype, 
        'vcode' => vcode
      }
    end #end method store_payment_info(values)
  
  
    
    def payment_info=(values)
      
      y = values["exp_date(1i)"]
      m = values["exp_date(2i)"]
      d = values["exp_date(3i)"].blank? ? 1 : values["exp_date(3i)"]
      values[:exp_date] = Date.parse("#{m}/#{d}/#{y}")
      
      
      self.salt = make_token
      pre_crypt_str = "#{values[:name_on_card]}=!=#{values[:card_number]}=!=#{values[:exp_date] ? values[:exp_date].strftime("%m/%d/%Y") : (Date.today - 1.year) }=!=#{values[:card_type]}=!=#{values[:vcode]}"
      self.payment_data = Security::SecurityManager.encrypt_with_salt(pre_crypt_str, self.salt)
    end #end method
    
    
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))
    end


    def make_token
      secure_digest(Time.now, (1..10).map{ rand.to_s })
    end
  
  
end #end class