class Order < ActiveRecord::Base
  
  attr_accessor :admin_created_order
  
  before_validation :set_shipping_address
  before_create :set_order_user, :run_final_qty_checks, :save_order_payment, :adj_item_inventory
  
  after_create :run_followup_tasks
  after_update :save_order_line_items, :save_shipping_labels
  
  belongs_to :order_vendor
  belongs_to :user
  belongs_to :coupon
  has_many :order_line_items
  has_many :shipping_labels
  has_and_belongs_to_many :gift_cards
  
  
  validates_presence_of :order_id, :order_date, :user_profile_type_id, :billing_first_name, :billing_last_name, 
    :billing_address, :billing_city, :billing_state_id, :billing_country_id, :billing_phone, :shipping_first_name,
    :shipping_last_name, :shipping_address, :shipping_city, :shipping_state_id, :shipping_zipcode, :shipping_country_id,
    :order_status_id, :payment_provider_id, :client_ip_address, :how_heard_option_id, :whoami
  
  validates_associated :order_line_items
  
  
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


  def run_followup_tasks
    self.send_later(:setup_order_shipping)
    self.send_later(:track_item_sold_counts)
    self.send_later(:update_gift_registry_wish_list)
    self.send_later(:track_coupons_used)
    self.send_later(:track_gift_cards_used)
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
    
    #look at order email, and if that email is assoc w/ a user account
    #we will attach the user_account to the order
    unless self.user
      usr = User.find_by_email(self.email)
      self.user = usr if usr
    end
    
  end #end method set_order_user



  def run_final_qty_checks

    return true if admin_created_order
    
    pass = true

    self.order_line_items.each do |li|
      unless li.variation.product.drop_ship
        avail_qty = ProductVariation.find(li.variation.id).qty_on_hand
        if avail_qty < li.quantity
          self.errors.add_to_base("The maximum available quantity of ''#{li.variation.full_title}' is #{avail_qty}")
          pass = false
        end 
      end 
    end
    
    return pass

  end #end method run_final_qty_checks


  def save_order_payment
    
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

      #save the packing configuration
      self.packing_configuration = self.shippments_as_html

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
  
  
  
  def setup_order_shipping
    
    return if @setup_order_shipping_done
    
    #create shipping numbers for each individual product on the order
    self.order_line_items.each do |line_item|
      1.upto(line_item.quantity) do |i| 
        line_item.shipping_numbers.build(:qty_description => "#{i} of #{line_item.quantity}")
      end
    end
  

    # create & save the ship_request & label
    # this process loops over the cart shippments, regardless of wether
    # we are using rate table or real time the shippments should be flushed out already
    for shippment in self.shippments

      unless shippment.drop_ship || shippment.courier == Courier::USPS

        for parcel in shippment.items
  
         #get the ship request info from the courier
        
         price, label, tracking_number = ShipManager.courier_ship_request(
           self.get_payment_shipping_address, 
           parcel.length,
           parcel.width,
           parcel.depth,
           parcel.weight, 
           1, 
           self.order_id)
 
         #write out the shipping label image
         label_path = Files::FileManager.save_shipping_label(label.path)


          #create a shipping label object on the order
          self.shipping_labels.build(:label => label_path, :tracking_number => tracking_number)
  
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
    
    
    @setup_order_shipping_done = true
    
    self.save
    
  end #end method setup_order_shipping
  
  
  
  def save_order_line_items
    order_line_items.each do |oli|
      if oli.should_destroy?
        oli.destroy
      else
        oli.save(false)
      end
    end
  end #end method save_order_line_items
  
  
  
  def save_shipping_labels
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


end #end class