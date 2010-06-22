class Order < ActiveRecord::Base
  
  attr_accessor :admin_created_order, :add_hoc_label_errors, :shipping_number_errors, 
    :skip_all_callbacks, :skip_new_callbacks
  
  before_validation :set_shipping_address
  
  before_create :set_order_user, :run_final_qty_checks, :save_order_payment, :adj_item_inventory, :set_vendors,
    :setup_shipping_numbers
  
  after_create :run_followup_tasks
  after_update :save_order_line_items, :save_shipping_labels #, :cancel_if_necessary
  
  before_update :cancel_if_necessary
  
  belongs_to :order_vendor
  belongs_to :user
  belongs_to :coupon
  belongs_to :billing_state, :class_name => "State", :foreign_key => "billing_state_id"
  belongs_to :billing_country, :class_name => "Country", :foreign_key => "billing_country_id"
  belongs_to :shipping_state, :class_name => "State", :foreign_key => "shipping_state_id"
  belongs_to :shipping_country, :class_name => "Country", :foreign_key => "shipping_country_id"
  has_many :order_line_items
  has_many :shipping_labels
  has_many :order_drop_ship_emails
  has_many :refunds
  has_and_belongs_to_many :gift_cards
  has_and_belongs_to_many :vendors
  
  
  validates_presence_of :order_id, :order_date, :user_profile_type_id, :billing_first_name, :billing_last_name, 
    :billing_address, :billing_city, :billing_state_id, :billing_country_id, :billing_phone, :shipping_first_name,
    :shipping_last_name, :shipping_address, :shipping_city, :shipping_state_id, :shipping_zipcode, :shipping_country_id,
    :order_status_id, :payment_provider_id, :client_ip_address, :how_heard_option_id, :whoami
  
  validates_associated :order_line_items
  #validates_associated :shipping_labels
  
  
  DORM_SHIP_DATE  = 1
  DORM_SHIP_PRIOR = 2
  DORM_SHIP_ASAP  = 3
  DORM_SHIP_OPTIONS = [
    [1, 'On a specific date'],
    [2, 'Prior to my arrival'],
    [3, 'ASAP']
  ]
  
  ORDER_STATUS_WAITING  = 1
  ORDER_STATUS_PARTIAL  = 2
  ORDER_STATUS_SHIPPED  = 3
  ORDER_STATUS_REFUNDED = 4
  ORDER_STATUS_CANCELED = 5
  ORDER_STATUS_OPTIONS = [
    [1, 'Awaiting Shipment'],
    [2, 'Partially Shipped'],
    [3, 'Shipped / Complete'],
    [4, 'Refunded'],
    [5, 'Canceled']
  ]
  ORDER_STATUS_PENDING = [1,2]
  
  PAYMENT_CREDIT_CARD = 1
  PAYMENT_OPTIONS = [
    [1, 'Credit Card']
  ]
  
  HOW_HEARD_OTHER_WEBSITE = 6
  HOW_HEARD_OTHER = 8
  HOW_HEARD_OPTIONS = [
    [1, 'Friend'],
    [2, 'Family'],
    [3, 'High School'],
    [4, 'College'],
    [5, 'Newspaper'],
    [6, 'Other Website'],
    [7, 'TV / Radio / Magazine'],
    [8, 'Other'],
    [9, 'Repeat Customer'],
    [10,'Email']
  ]
  HOW_HEARD_INPUT_REQUIRED = [6,8]
  
  WHO_AM_I_OPTIONS = [
    ["College Student", "College Student"],
		["High School Student", "High School Student"],
		["Parent", "Parent"],
		["Other", "Other"]
  ]
  
  ADDRESS_SAME      = 1
  ADDRESS_DIFFERENT = 2
  ADDRESS_DORM      = 3
  ADDRESS_OPTIONS = [
    [1, 'Billing and Shipping are the same'],
    [2, 'Billing and Shipping are different'],
    [3, 'Dorm Shipping']
  ]
  
  
  composed_of :total_giftcards, 
    :class_name => "Money", 
    :mapping => %w(int_total_giftcards cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  composed_of :total_coupon, 
    :class_name => "Money", 
    :mapping => %w(int_total_coupon cents),
    :converter => Proc.new {|amount| amount.to_money }

  composed_of :total_discounts, 
    :class_name => "Money", 
    :mapping => %w(int_total_discounts cents),
    :converter => Proc.new {|amount| amount.to_money }

  composed_of :subtotal, 
    :class_name => "Money", 
    :mapping => %w(int_subtotal cents),
    :converter => Proc.new {|amount| amount.to_money }

  composed_of :tax, 
    :class_name => "Money", 
    :mapping => %w(int_tax cents),
    :converter => Proc.new {|amount| amount.to_money }

  composed_of :shipping, 
    :class_name => "Money", 
    :mapping => %w(int_shipping cents),
    :converter => Proc.new {|amount| amount.to_money }

  composed_of :grand_total, 
    :class_name => "Money", 
    :mapping => %w(int_grand_total cents),
    :converter => Proc.new {|amount| amount.to_money }

 
  def validate
    unless self.add_hoc_label_errors.blank?
      self.add_hoc_label_errors.each do |err|
        self.errors.add_to_base(err)
      end
    end
    
    unless self.shipping_number_errors.blank?
      self.shipping_number_errors.each do |err|
        self.errors.add_to_base(err)
      end
    end
    
  end #end method validate
 
 
  def cancel_if_necessary
    return if self.skip_all_callbacks
    if self.order_status_id == Order::ORDER_STATUS_CANCELED
      #self.send_later(:cancel_order)
      return self.cancel_order
    end
  end
 
  
  def how_heard_txt
    heard = nil
    Order::HOW_HEARD_OPTIONS.each {|o| heard = o if o.first == self.how_heard_option_id }
    if HOW_HEARD_INPUT_REQUIRED.include?(heard.first)
      self.how_heard_option_value
    else
      heard.last
    end
  end #end method how_heard_txt



  def run_followup_tasks
    return if self.skip_all_callbacks
    return if self.skip_new_callbacks

    
    self.track_coupons_used
    self.track_gift_cards_used
    
    self.send_later(:setup_order_shipping)
    self.send_later(:track_item_sold_counts)
    self.send_later(:update_gift_registry_wish_list)
    Notifier.send_later(:deliver_customer_order_notification, self)
    
  end #end method run_followup_tasks


  
  def track_coupons_used
    #update any coupon used on the order
    if self.coupon
      unless self.coupon.reusable
        self.coupon.used = true
        self.coupon.save!
      end
    end #end if coupon
  end #end method track_coupons_used
  
  
  
  def track_gift_cards_used
    
    #update any gift cards used on the order
    self.gift_cards.sort! {|x,y| x.current_amount <=> y.current_amount} #sort smallest amount first
    
    gc_ids = []
    gc_total = self.total_giftcards

    #alter the gc balances on used cards
    self.gift_cards.each do |card|
      
      gc_ids << card.id

      if gc_total.cents > 0

        #adjust amount as necessary
        if gc_total >= card.current
          gc_total -= card.current
          card.current_amount = 0
        else
          card.current -= gc_total
          gc_total = 0
        end

        card.save! #save the adjustments to the current_amount

      end #end if gc_total > 0

    end #end card.gift_cards.each
    
    
    #log giftcards used on the order
    self.gift_card_ids = gc_ids
    
  end #end method track_gift_cards_used
  


  def track_item_sold_counts
    self.order_line_items.each do |item|
      item.variation.update_attributes(:sold_count => (item.variation.sold_count += 1))
    end
  end #end method track_item_sold_counts
  
  
  
  def update_gift_registry_wish_list
    
    self.order_line_items.each do |item|
      
      #if the item being purchased was from a gift registry debit the registry
      if item.gift_registry_item
      
        #update the received quantity of the registry item to the item the user is purchasing
        item.gift_registry_item.update_attributes(:received_qty => (item.gift_registry_item.received_qty += item.quantity))
        
      end #end if item.gift_registry_item
      
      
      # if the item being purchased was from a wish list debit the list
      if item.wish_list_item
        
        #update the got qty
        item.wish_list_item.update_attributes(:got_qty => (item.wish_list_item.got_qty += item.quantity))
        
      end #end if item.wish_list_item
      
    end #end each
    
  end #end method update_gift_registry_wish_list



  def set_order_user
    return if self.skip_all_callbacks
    return if self.skip_new_callbacks
    
    #look at order email, and if that email is assoc w/ a user account
    #we will attach the user_account to the order
    unless self.user
      usr = User.find_by_email(self.email)
      self.user = usr if usr
    end
    
  end #end method set_order_user



  def run_final_qty_checks
    return if self.skip_all_callbacks
    return if self.skip_new_callbacks

    return true if admin_created_order
    
    pass = true

    self.order_line_items.each do |li|
      unless li.variation.product.drop_ship
        avail_qty = ProductVariation.find(li.variation.id).qty_on_hand
        if avail_qty < li.quantity
          self.errors.add_to_base("The maximum available quantity of ''#{li.variation.full_title}' is #{avail_qty} please call 1-866-502-DORM for special orders")
          pass = false
        end 
      end 
    end
    
    return pass

  end #end method run_final_qty_checks



  def save_order_payment
    return if self.skip_all_callbacks
    return if self.skip_new_callbacks
    
    pass = true
    
    #charge the user for the order
    @payment_result = Payment::PaymentManager.make_payment(
      self.grand_total, 
      self.payment_provider_id, 
      self.payment_info, 
      self.get_payment_billing_address, 
      self.get_payment_shipping_address,
      self.order_id)
    
    
    if RAILS_ENV == 'development'
      @payment_result[:success] = true
      @payment_result[:transaction_number] = "123456"
      @payment_result[:message] = "Success: GOOD TO GO"
    end
    
    
    if @payment_result[:success]
      
      #Make the order_date the time the payment source was billed
      self.order_date = Time.now

      #save the transaction number
      self.payment_transaction_number = @payment_result[:transaction_number]


      #store transaction specific data
      if self.grand_total.cents == 0
        self.payment_transaction_data = ""
      else
        
        case payment_provider_id

          when Order::PAYMENT_CREDIT_CARD
            self.payment_transaction_data = Security::SecurityManager.encrypt(self.payment_info['card_number'])

        end #end case
        
      end #end if grand_total == 0

    else
      self.errors.add_to_base(@payment_result[:message])
      pass = false
    end
    
    
    
    return pass
    
  end #end method save_order_payment
  
  
  
  def adj_item_inventory
    return if self.skip_all_callbacks
    return if self.skip_new_callbacks
    
    #alter the inventory of the order items & on_hold qty
    for item in self.order_line_items
      
      #debit inventory 
      unless item.variation.product.drop_ship 
        new_onhand = item.variation.qty_on_hand - item.quantity #debit on-hand
        new_onhold = item.variation.qty_on_hold + item.quantity #credit on-hold
        item.variation.update_attributes(:qty_on_hand => new_onhand, :qty_on_hold => new_onhold)
        @inventory_updated = true
      end
      
      #debit inventory for any optional variations
      for ov in item.order_line_item_product_as_options
      
        optional_variation = ProductVariation.find_by_product_number(ov.product_number)
      
        unless optional_variation.product.drop_ship
          new_onhand = optional_variation.qty_on_hand - item.quantity #debit on-hand
          new_onhold = optional_variation.qty_on_hold + item.quantity #credit on-hold
          optional_variation.update_attributes(:qty_on_hand => new_onhand, :qty_on_hold => new_onhold)
          @optional_inventory_updated = true
        end
        
        #track the qty sold of the optional product
        optional_variation.update_attributes(:sold_count => (optional_variation.sold_count += 1))
        
      end #end for product_optional_variations
      
    end #end for item in @order.order_line_items
    
  end #end method adj_item_inventory
  
  
  
  def set_vendors
    self.vendors = self.all_vendors_from_line_items
  end #end method set_vendors
  
  
  
  def setup_shipping_numbers
    
    #create shipping numbers for each individual product on the order
    self.order_line_items.each do |line_item|
      1.upto(line_item.quantity) do |i| 
        line_item.shipping_numbers.build(:qty_description => "#{i} of #{line_item.quantity}")
      end
    end
    
  end #end method setup_shipping_numbers
  
  
  
  def setup_order_shipping
    
    return if @setup_order_shipping_done
    
    #save the packing configuration
    self.packing_configuration = self.shippments_as_html
    

    # create & save the ship_request & label
    # this process loops over the cart shippments, regardless of wether
    # we are using rate table or real time the shippments should be flushed out already
    for shippment in self.shippments

      unless shippment.drop_ship || shippment.courier == Courier::USPS

        for parcel in shippment.items
  
         #get the ship request info from the courier

      
          #USING UPS
          label_path, tracking_number, identification_number = ShipManager.courier_ship_request(
             self.get_payment_shipping_address, 
             parcel.length,
             parcel.width,
             parcel.depth,
             parcel.weight, 
             1, 
             self.order_id)

          #create a shipping label object on the order
          self.shipping_labels.build(
            :label => label_path, 
            :tracking_number => tracking_number, 
            :identification_number => identification_number
          )
  
          #we can save the tracking number on the line_item.shipping_numbers but we can only
          #do it if there is a single parcel in the shippment.  This is because there is a possibility
          #that someone could have two of the same product in different parcels. So....
          if shippment.items.length == 1
    
            #iterate over the products in the parcel, and ultimatley find the line item in the order 
            #that references that same product, when found, set the tracking number for this parcel
            #in all the shipping_number objects that belong to that line_item
            for product_package in parcel.items
      
              #get the product variation
              variation = product_package.product_variation
      
              #now we need to find any order_line_items that have this same product
              line_item = self.order_line_items.detect {|item| item.variation == variation}
      
              #now we need to set the tracking info for the shipping_numbers for this line item
              line_item.shipping_numbers.each do |shipping_number|
                shipping_number.courier_id = Courier.current_courier
                shipping_number.tracking_number = tracking_number
              end #end shipping_numbers.each
      
            end #end loop over parcel.items
            
            #since we set tracking numbers automatically, lets change the order
            #status to partially shipped.
            self.order_status_id == Order::ORDER_STATUS_PARTIAL
    
          end #end if single parcel

        end #end parcels

      end #end unless drop_ship

    end #end shippments

    
    self.order_line_items.each do |line_item|
      line_item.shipping_numbers.each do |num|
        num.save(false)
      end
    end
    

    @setup_order_shipping_done = true
    
    self.skip_all_callbacks = true
    self.save
    
  end #end method setup_order_shipping
  
  
  
  def save_order_line_items
    return if self.skip_all_callbacks
    order_line_items.each do |oli|
      if oli.should_destroy?
        oli.destroy
      else
        oli.save(false)
      end
    end
  end #end method save_order_line_items
  
  
  
  def save_shipping_labels
    return if self.skip_all_callbacks
    shipping_labels.each do |sl|
      if sl.should_destroy?
        sl.destroy
      else
        sl.save(false)
      end
    end
  end #end method save_shipping_labels
  
  
  
  def shippments_as_html
    
    output = "\n<div class=\"shippment_list\">\n"
    
    for shippment in self.shippments
      
      output += "  <div class=\"shippment\">\n"
    	output += "    <div class=\"summary_line\">Origin: #{shippment.origin} #{((shippment.drop_ship)? '<b class="dropship">DROPSHIP</b>' : '')} </div>\n"
    	output += "    <div class=\"summary_line\">Total Weight: #{shippment.items.sum {|parcel| parcel.weight }} </div>\n"
    	output += "    <div class=\"summary_line\">Parcels: #{shippment.items.length}<div>\n"
    	output += "    <div class=\"summary_line\">Courier: #{Courier.find(shippment.courier).courier_name}<div>\n"
    	output += "      <ul class=\"shippment_items\">\n"
    		
    		for p in shippment.items
    			output += "        <li class=\"parcel\">#{p.length}(l) x #{p.width}(w) x #{p.depth}(d) @ #{p.weight} lbs, contains #{p.items.length} product(s) #{((p.ship_alone)? '-- product ships alone' : '')}\n"
    			output += "            <ul class=\"products\">\n"
    			
    			for pp in p.items
    			  output += "              <li class=\"product_name\">#{pp.product_variation.full_title}</li>\n"
  			  end
    			
    			output += "            </ul>\n"
    			output += "        </li>\n"
    		end
    		
    	output += "    </ul>\n"
    	
    	output += "  </div>\n"
    	
  	end
  	
  	output += "</div>\n"
  	
  	output
  end #end method shippments_as_html
  
  
  
  def get_payment_billing_address
    billing_address = { 
      :name     => "#{self.billing_first_name} #{self.billing_last_name}",
      :address1 => "#{self.billing_address}",
      :address2 => "#{self.billing_address2}",
      :city     => "#{self.billing_city}",
      :state    => "#{State.find(self.billing_state_id).abbreviation}",
      :country  => "#{Country.find(self.billing_country_id).abbreviation}",
      :zip      => "#{self.billing_zipcode}"
    }
  end #end method get_payment_billing_address
  
  
  
  def get_payment_shipping_address
    shipping_address = { 
      :name     => "#{self.shipping_first_name} #{self.shipping_last_name}",
      :address1 => "#{self.shipping_address}",
      :address2 => "#{self.shipping_address2}",
      :city     => "#{self.shipping_city}",
      :state    => "#{State.find(self.shipping_state_id).abbreviation}",
      :country  => "#{Country.find(self.shipping_country_id).abbreviation}",
      :zip      => "#{self.shipping_zipcode}",
      :phone    => "#{self.shipping_phone}"
    }

    #add college name as company_name if it is dormship
    if self.user_profile_type_id == ADDRESS_DORM
      shipping_address[:company_name] = self.dorm_ship_college_name
    end
    
    shipping_address
  end #end method get_payment_shipping_address

  

  def self.generate_uniq_order_id

    num = Time.now.strftime("%m%d-")
    5.times {num += (rand(9)).to_s}
    found = Order.find_by_order_id(num)

    until found.blank?
      num = Time.now.strftime("%m%d-")
      5.times {num += (rand(9)).to_s}
      found = Order.find_by_order_id(num)
    end

    num
  end #end method generate_uniq_order_id



  def set_shipping_address
    return if self.skip_all_callbacks
    
    return unless self.new_record?
    
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
  
  
  
  def status_text
    
    ORDER_STATUS_OPTIONS.each do |status_arr|
      if status_arr.first == self.order_status_id
        return status_arr.last
      end
    end
    
  end #end method status



  def order_line_item_attributes=(order_line_item_attributes)
    
    order_line_item_attributes.each do |attributes|
      if attributes[:id].blank?
        oli = order_line_items.build(attributes)
      else
        oli = order_line_item_attributes.detect {|x| x.id == attributes[:id].to_i}
        oli.attributes = attributes
      end
      
    end #end loop
    
  end #end method order_line_item_attributes=



  def credit_card_attributes=(credit_card_attributes)
    self.payment_info = credit_card_attributes
  end #end method credit_card_attributes=(credit_card_attributes)



  def payment_info
    if @payment_values.class == Array
      @payment_values.first
    else
      @payment_values
    end
  end #end method store_payment_info(values)
  
  
    
  def payment_info=(values)
    @payment_values = values
  end #end method
  
  
  
  def shippments
    if @shippments.blank?
      @shippments = ShipManager.calculate_shippments(self.order_line_items, self.shipping_zipcode)
    else
      @shippments
    end
  end #end method shippments
  
  
  
  def unsent_dropships?
    
    line_item_vendors = [] #array of vendor IDs that have line items
    emailed_vendors = [] #array of vendors that were emailed
    
    #get an array of vendor ids for drop_ship items on this order
    self.order_line_items.each do |line_item| 
        if line_item.product_drop_ship
          v = Vendor.find_by_company_name(line_item.vendor_company_name) unless line_item.vendor_company_name.blank?
          line_item_vendors << v.id if v
        end
    end
    
    #get a list of vendor ids that were sent drop_ship emails for this order
    self.order_drop_ship_emails.each {|email| emailed_vendors << email.vendor_id}
    
    #sort & compare the lists
    line_item_vendors.sort! {|x,y| x <=> y}
    emailed_vendors.sort! {|x,y| x <=> y}
    
    #return the comparison
    pass = false
    line_item_vendors.each {|vend| pass = true unless emailed_vendors.include? vend}
    pass
  end #end method unsent_dropships?
  
  

  def dorm_w_unsent_dropships?
    
    if self.user_profile_type_id == Order::ADDRESS_DORM
      unsent_dropships?
    else
      false
    end
    
  end #end method dorm_w_unsent_dropships?
  
  
  
  def dorm_ship?
    self.user_profile_type_id == Order::ADDRESS_DORM
  end #end method dorm_ship?
  
  

  def shipped_complete?
    self.order_status_id == Order::ORDER_STATUS_SHIPPED
  end #end method shipped_complete?
  
  
  
  def has_usps?
    missing_non_dropship_tracking? && shipping_labels.empty?
  end #end method has_usps?
  
  
  
  def dropship_only?
    !self.order_line_items.collect {|oli| oli.product_drop_ship }.include?(false)
  end #end method dropship_only?
  
  
  
  def is_processing?
    self.processing
  end #end method is_processing?
  
  
  
  def is_processed?
    self.processed
  end #end method is_processed?
  
  

  def has_dropship?
    ds = false
    
    self.order_line_items.each do |line_item|
        if line_item.product_drop_ship
          ds = true
          return ds
        end
    end
    ds
  end #end has_dropship?
  
  

  def invalid_address_alert?
    alert = false
    keywords = ["AFO", "Box", "BOX", "PO", "P.O.", "PO Box", "APO", "AFO", "AP"]
    keywords.each {|k| alert = true if self.shipping_address.rindex(k)}
    keywords.each {|k| alert = true if self.shipping_city.rindex(k)}
    alert
  end #end method invalid_address_alert?
  
  

  def missing_non_dropship_tracking?
    missing = false
    self.order_line_items.each do |line_item|

        unless line_item.product_drop_ship
          line_item.shipping_numbers.each do |number| 
            missing = true if number.tracking_number.blank?
          end
        end

    end
    missing
  end #end method missing_non_dropship_tracking?



  def canceled?
    self.order_status_id == Order::ORDER_STATUS_CANCELED || self.order_status_id == Order::ORDER_STATUS_REFUNDED
  end
  
  
  
  def has_comments?
    !self.order_comments.blank?
  end #end method has_comments?
  
  
  
  def full_refund
    
    # HACK for bad auth.net result after ruby 1.8.7 upgrade
    if RAILS_ENV == 'development'
      result = self.refunds.create(
        :transaction_id   => "123456", 
        :amount           => grand_total,
        :user_id          => User.current_user.id, 
        :response_data    => "full_refund", 
        :message          => "Refunded full total", 
        :success          => true)
    else
      
      begin
        result = Payment::PaymentManager.make_full_refund(self, grand_total)
      rescue Exception => e
        self.errors.add_to_base(e.message)
        return false
      end
      
    end #end if-else
    
    
    return result
    
  end #end method full_refund
  
  
  
  def cancel_order
    
    #del the order's shipping labels
    unless kill_all_shipping_labels
      return false
    end
    
    
    #refund the full order amount
    if self.grand_total.cents > 0
      
      unless refund = full_refund
        return false
      else
        refund_pass = refund.success
      end
      
    else
      refund_pass = true
    end
    
    
    if refund_pass
    
      self.re_stock_canceled_inventory
    
      Notifier.send_later(:deliver_order_canceled, self)
    
    else
      self.errors.add_to_base(refund.message)
      return false
    end #end if refund success
    
    
    return refund_pass
    
  end #end method cancel_order
  
  
  
  def re_stock_canceled_inventory
    
    #update inventory levels
    order_line_items.each do |line_item|
      
      variation = line_item.variation
      
      unless line_item.product_drop_ship
        
        if variation
          
          if self.processed
            new_onhold = variation.qty_on_hold # don't update on-hold if processed
            new_onhand = variation.qty_on_hand + line_item.quantity
          else
            new_onhold = variation.qty_on_hold - line_item.quantity
            new_onhand = variation.qty_on_hand + line_item.quantity
          end
          variation.update_attributes(:qty_on_hand => new_onhand, :qty_on_hold => new_onhold)
          
        end #end if
      
      end #end unless
      
      
      for ov in line_item.order_line_item_product_as_options

        optional_variation = ProductVariation.find_by_product_number(ov.product_number)

        unless optional_variation.product.drop_ship
          
          if self.processed
            new_onhand = optional_variation.qty_on_hand + line_item.quantity #credit on-hand
            new_onhold = optional_variation.qty_on_hold # don't update on-hold if processed
          else
            new_onhand = optional_variation.qty_on_hand + line_item.quantity #credit on-hand
            new_onhold = optional_variation.qty_on_hold - line_item.quantity #debit on-hold
          end
          optional_variation.update_attributes(:qty_on_hand => new_onhand, :qty_on_hold => new_onhold)
          
        end

      end #end for product_optional_variations
      
      
    end #end order_line_items.each
    
  end #end method re_stock_canceled_inventory
  
  
  
  def kill_all_shipping_labels
    
    self.shipping_labels.each do |label|
      
      #void the label with the courier
      begin
        ShipManager.void_shipping_label(label)
      rescue ActiveMerchant::Shipping::ResponseError => e
        
        #if we are not testing UPS
        if APP_CONFIG['ups']['testing'].to_i != 1
          self.errors.add_to_base(e.message)
          return false
        end
        
      end
      
      #del any tracking #s filled from this label
      order_line_items.each do |line_item|
        line_item.shipping_numbers.each do |shipping_number|
          
          if shipping_number.tracking_number == label.tracking_number
            shipping_number.courier_id = nil
            shipping_number.tracking_number = nil
            shipping_number.save
          end
          
        end
      end
      
      
      #del the label itself
      label.destroy
      
    end #end labels.each
    
  end #end method kill_all_shipping_labels
  
  
  
  def update_order_ship_status
    
    unless self.canceled?
    
      num_shipped = 0
      num_total = 0

      self.order_line_items.each do |line_item|
      
        line_item.shipping_numbers.each do |shipping_number|
        
          #add the shipping number to the total
          num_total += 1
        
          #add to the number shipped unless the tracking
          # number is missing
          unless shipping_number.tracking_number.blank?
            num_shipped += 1
          end
        
        end #end shipping_numbers
      
      end #end line_items
    
    
      set_status = Proc.new do
        
        if num_shipped == 0
          self.order_status_id = Order::ORDER_STATUS_WAITING
        elsif num_shipped < num_total
          self.order_status_id = Order::ORDER_STATUS_PARTIAL
        elsif num_shipped == num_total
          self.order_status_id = Order::ORDER_STATUS_SHIPPED
        end
        
      end #end proc
      
      
      if User.current_user.is_admin?
        
        #do whatever you want
        set_status.call
        
      else
        
        if self.dropship_only?
          
          set_status.call
          
        else
          
          #if it is NOT going to be shipped complete
          if num_shipped != num_total
            
            set_status.call
            
          else
            
            #this IS going to mark it as SHIPPED COMPLETE
            
            if is_processed?
              set_status.call
            else
              self.order_status_id = Order::ORDER_STATUS_SHIPPED
            end
            
          end
          
        end #end if dropship_only?
        
      end #end is_admin?
  
      
      #save any status change
      self.skip_all_callbacks = true
      self.save
    
    end #end unless canceled?
      
  end #end method update_order_ship_status
  
  
  
  def drop_ship_vendors
    ds_vendors = []
    
    #get an array of vendors for drop_ship items on this order
    order_line_items.each do |line_item| 
        if line_item.product_drop_ship
          ds_vendors << Vendor.find_by_company_name(line_item.vendor_company_name) unless line_item.vendor_company_name.blank?
        end
    end
    
    #kill any duplicates
    ds_vendors.uniq!
    
    ds_vendors
  end #end method drop_ship_vendors
  
  
  
  def all_vendors_from_line_items
    all_vendors = []
    
    #get an array of vendors for drop_ship items on this order
    order_line_items.each do |line_item| 
      all_vendors << Vendor.find_by_company_name(line_item.vendor_company_name) unless line_item.vendor_company_name.blank?
    end
    
    #kill any duplicates
    all_vendors.uniq!
    
    all_vendors
  end #end method all_vendors_from_line_items
  
  
  
  def send_drop_ship_emails

    begin

      #loop over all the vendors that have items on the order
      self.drop_ship_vendors.each do |vendor|
      
        if vendor.vendor_managers.empty?
          self.errors.add_to_base("No managers to notify at: #{vendor.company_name}")
          return false
        end
      
        #look up all vendor managers for a vendor
        vendor.vendor_managers.each do |manager|
        
          if manager.email
            
            #send the email
            Notifier.deliver_vendor_dropship_notification(manager, vendor, self)

            #create a drop_ship_email
            eml = self.order_drop_ship_emails.build(
              :vendor_id => vendor.id,
              :email => manager.email,
              :vendor_company_name => vendor.company_name)
            eml.save!
            
          end #end if manager.user.email
        
        end #end vendor_managers.each
      
      end #end vendors.each
      
      
    rescue Exception => e
      self.errors.add_to_base("Drop Ship Email Error: #{e.to_s}")
      return false
    end
    
    return true
    
  end #end method send_drop_ship_emails
  
  
  
  def send_individual_drop_ship_emails(vendor)
    
    begin

      send_to = [] #array of users to email

      #look up all vendor managers for a vendor
      vendor.vendor_managers.each do |manager|
      
        send_to << manager if manager.email
        
      end #end vendor_managers.each
      
      if send_to.empty?
        self.errors.add_to_base("No managers to notify at vendor")
        return false
      end
      
      #now that we have an error free list of emails to send
      # lets do it
      send_to.each do |user|
        
        #send the email
        Notifier.deliver_vendor_dropship_notification(user, vendor, self)
    
        #create a drop_ship_email
        eml = self.order_drop_ship_emails.build(
          :vendor_id => vendor.id,
          :email => user.email,
          :vendor_company_name => vendor.company_name)
        eml.save!
          
      end #end send_to.each
      

    rescue
      self.errors.add_to_base("Drop Ship Email Error: #{e.messsage}")
      return false
    end
    
    return true
  end #end method send_individual_drop_ship_emails
  
  

  def updated_shipping_number_attributes=(shipping_num_attributes)
    
    self.shipping_number_errors = []
    
    attributes = shipping_num_attributes.first
    
    if attributes[:id].blank?
      self.shipping_number_errors << "You must select a tracking number to update"
      return false
    end
    
    attributes[:id].each do |shipping_number_id|
      num = ShippingNumber.find(shipping_number_id)
      if num
        num.update_attributes(:courier_id => attributes[:courier_id], :tracking_number => attributes[:tracking_number])
      end
    end
    
    Notifier.send_later(:deliver_updated_tracking, self)
    
  end #end method updated_shipping_number_attributes(shipping_num_attributes)



  def ad_hoc_shipping_label_attributes=(form_data)
    
    #raise "#{attributes.first[:name]}"
    attributes = form_data.first
    
    self.add_hoc_label_errors = []
    
    
    begin
      
      shipping_address = { 
        :name     => attributes[:name],
        :address1 => attributes[:address],
        :address2 => attributes[:address2],
        :city     => attributes[:city],
        :state    => State.find(attributes[:state_id]).abbreviation,
        :country  => Country.find(attributes[:country_id]).abbreviation,
        :zip      => attributes[:zip],
        :phone    => attributes[:phone]
      }
      shipping_address[:company_name] = attributes[:company_name] unless attributes[:company_name].blank?
    
      length = attributes[:length].to_f
      width = attributes[:width].to_f
      depth = attributes[:depth].to_f
      weight = attributes[:weight].to_f
    

      # USING UPS
      label_path, tracking_number, identification_number = ShipManager.courier_ship_request(
         shipping_address, 
         length,
         width,
         depth,
         weight, 
         1, 
         self.order_id)

      self.shipping_labels.create(
        :label => label_path, 
        :tracking_number => tracking_number, 
        :identification_number => identification_number
      )
      
    rescue Exception => e
      self.add_hoc_label_errors << "ERROR CALCULATING SHIPPING - " + e.message
    end
    
    
  end #end method ad_hoc_shipping_label_attributes=(label_attributes)


  def when_to_dorm_ship
    
    case self.dorm_ship_time_id
  		when Order::DORM_SHIP_DATE
  			self.dorm_ship_ship_date.strftime("%m/%d/%Y")
  		when Order::DORM_SHIP_PRIOR
  			"Prior to customer's arrival at their dorm"
  		when Order::DORM_SHIP_ASAP
  			"ASAP"
			else
			  "Error"
  	end
  end #end method when_to_dorm_ship


  def self.new_from_cart(cart)
    
    #setup a new order
    order                 = Order.new
    order.order_date      = Time.now
    order.order_status_id = Order::ORDER_STATUS_WAITING
    order.order_id        = Order.generate_uniq_order_id
    order.order_vendor_id = OrderVendor::DORMBUYS
    
    #remove non-relevant cart attributes
    cart_attributes = cart.attributes
    cart_attributes.delete("id")
    cart_attributes.delete("salt")
    cart_attributes.delete("payment_data")
    cart_attributes.delete("created_at")
    cart_attributes.delete("updated_at")
    
    #now set the order attributes from the cart
    order.attributes = cart_attributes
    
    
    #create order line items from cart items
    cart.cart_items.each do |cart_item|
    
      #create the order line item
      oli                               = order.order_line_items.build
      oli.item_name                     = cart_item.product_variation.full_title
      oli.quantity                      = cart_item.quantity
      oli.vendor_company_name           = cart_item.product_variation.product.vendor.company_name
      oli.product_manufacturer_number   = cart_item.product_variation.manufacturer_number
      oli.product_number                = cart_item.product_variation.product_number
      oli.unit_price                    = cart_item.unit_price
      oli.total                         = cart_item.total_price
      oli.product_drop_ship             = cart_item.product_variation.product.drop_ship
      #oli.product_drop_ship             = Product.find(cart_item.product_variation.product_id).drop_ship
      oli.warehouse_location            = cart_item.product_variation.warehouse_location
      
      #set the wish_list and gift_registry tracking ids
      oli.wish_list_item_id             = cart_item.wish_list_item_id unless cart_item.wish_list_item_id.blank?
      oli.gift_registry_item_id         = cart_item.gift_registry_item_id unless cart_item.gift_registry_item_id.blank?
      
      #set produc options, and poducts as options
      oli.pov_ids                       = cart_item.pov_ids
      oli.paov_ids                      = cart_item.paov_ids
            
    end #end cart_items
    
    
    #set payment data
    order.payment_info    = cart.grand_total.cents == 0 ? "" : cart.order_payment
    
    
    #set totals
    order.subtotal        = cart.subtotal
    order.tax             = cart.tax
    order.shipping        = cart.shipping
    order.total_giftcards = cart.total_gift_cards
    order.total_coupon    = cart.total_coupons
    order.total_discounts = Money.new(0)
    order.grand_total     = cart.grand_total.cents <= 0 ? Money.new(0) : cart.grand_total
    
    return order
  end #end method new_from_cart(params)


  def shipping_numbers
    nums = []
    self.order_line_items.each do |oli|
      oli.shipping_numbers.each do |num|
        unless num.tracking_number.blank?
          unless nums.collect(&:tracking_number).include?(num.tracking_number)
            nums << num
          end
        end
      end
    end
    nums.uniq
  end #end method tracking_numbers


end #end class