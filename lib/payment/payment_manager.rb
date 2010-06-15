require 'money'

class Payment::PaymentManager

  include ActiveMerchant::Billing
  
  # creates an ActiveMerchant credit card object from the given data
  def self.credit_card(type, number, exp_date, vcode, first_name='blank', last_name='blank')
    defaults = {
      :number => number,
      :month => exp_date.month,
      :year => exp_date.year,
      :first_name => first_name,
      :last_name => last_name,
      :verification_value => vcode,
      :type => type
    }
    CreditCard.new(defaults)
  end #end method self.credit_card
  
  
  
  # creates a hash of address data.  notable fields are:
  #
  # {
  #  :name => 'john smith', :address1 => '1234 some street', :city => 'Louisville', 
  #  :state => 'KY', :zip => '40202', :country => 'US'
  # }
  def self.billing_address(options = {})
    { 
      :first_name => '',
      :last_name  => '',
      :address1   => '',
      :address2   => '',
      :company    => '',
      :city       => '',
      :state      => '',
      :zip        => '',
      :country    => 'US',
      :phone      => '',
      :fax        => ''
    }.update(options)
  end #end method self.billing_address()
  

  ##
  # method to bill a customer's payment account.  returns a hash of result info
  #
  # * @param Money amount - grand total for the order
  # * @param Integer pmnt_type - Payment type taken from the order payment provider id
  # * @param Hash pmnt_info - Payment info taken from the order.payment_info
  # * @param Hash billing_info - order billing information in a active merchant ready hash
  # * @param Hash shipping_info - order shipping information in a active merchant ready hash
  # * @param String order_id - the order's order id
  # * @return Hash - returns a hash with keys :success, :message, :transaction_number
  ##
  def self.make_payment(amount, pmnt_type, pmnt_info, billing_info, shipping_info, order_id)
    
    result = Hash.new #hash to return later
   
    #handle payments for 0.00
    if amount.cents == 0
      result[:success] = true
      result[:transaction_number] = "000000"
      result[:message] = "Success: " + "Order approved"
      return result
    end
    
    
    
    #create a money object.  
    #amount_to_charge = Money.new((amount*100).to_i) # US dollars
    amount_to_charge = amount
    
    
    #if pmnt type is credit, we can add else conditions for other payment types
    if pmnt_type == Order::PAYMENT_CREDIT_CARD
      
      #sets active merchant into test mode if we aren't in production mode
      ActiveMerchant::Billing::Base.mode = :test if RAILS_ENV != "production"
      
      #create the payment info for a credit card
      payment_info = {
        :first_name => pmnt_info['name_on_card'].split(" ").first.to_s,
        :last_name => pmnt_info['name_on_card'].split(" ").last.to_s,
        :number => pmnt_info['card_number'].to_s,
        :month => pmnt_info['expiration_date(2i)'].to_s,
        :year => pmnt_info['expiration_date(1i)'].to_s,
        :verification_value => pmnt_info['vcode'].to_s,
        :type => pmnt_info['card_type'].to_s
      }
      
      #make a new credit card object
      creditcard = ActiveMerchant::Billing::CreditCard.new(payment_info)

      #validate the card
      if creditcard.valid?

        #create a new gateway to authorize.net
        gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new({
          :login => APP_CONFIG['authorize_net']['login_id'].to_s,            #API Login ID
          :password => APP_CONFIG['authorize_net']['transaction_key'].to_s   #Transaction Key
        })

        #setup the options hash
        options = {
          :address => shipping_info,
          :billing_address => billing_info,
          :order_id => order_id,
          :description => "Dormbuys.com online order"
        }

        #attempt to authorize the card
        response = gateway.authorize(amount_to_charge, creditcard, options)

        
        #create an audit logger                                
        #logfile = File.open("#{RAILS_ROOT}/log/audit.log", 'a')
        #logfile.sync = true                                    
        #audit_logger = AuditLogger.new(logfile)                                                              
        #audit_logger.info response.to_s                                  
        
        

        if response.success?
          
          #capture the funds
          gateway.capture(amount_to_charge, response.authorization)
          
          #setup the successful hash
          result[:success] = true
          result[:transaction_number] = response.authorization
          result[:message] = "Success: " + response.message.to_s
          
          result[:message] += '<br /><br />' + response.to_yaml if RAILS_ENV == 'development'

        else
          
          #setup the error hash
          result[:success] = false
          result[:message] = "Error: " + response.message.to_s

          result[:message] += '<br /><br />' + response.to_yaml if RAILS_ENV == 'development'
        end

      else
        result[:success] = false
        result[:message] = "Error: Credit card is not valid" # + creditcard.validate.to_s
      end
      
      result #return the result hash
      
    end #end if on pmnt_type
    

    
    
    
    
  end #end method make_payment(amount, pmnt_type, pmnt_info, billing_info, shipping_info)
  
  
  def self.make_full_refund(order, amount)
    
    #we need to see if there were any gift cards on the order, and if so
    #we need to put money back on the gift cards first
    giftcards = order.gift_cards.find(:all, :order => "int_original_amount ASC, int_current_amount ASC")
    
    #get the total that was on gift cards
    gc_amount = order.total_giftcards
    
    #loop to credit money back
    for card in giftcards
   
      #if current card value + amount is more than the orig gift card
      if (card.current + gc_amount) > card.original
        
        gc_amount -= card.original #remove the cards original amount from the total
        card.current = card.original #put the original back on the card
        card.save
        
        #log the gc refund
        result = order.refunds.create(
          :transaction_id   => order.payment_transaction_number, 
          :amount           => card.original,
          :user_id          => User.current_user.id, 
          :response_data    => "giftcard_refund", 
          :message          => "Refunded #{card.original.format} to gift card #{card.giftcard_number}", 
          :success          => true)
      
      #if current card value + amount is less than or = original amount
      elsif (card.current + gc_amount) <= card.original
        
        card.current += gc_amount #put all the remainder on this card
        card.save
        
        #log the gc refund
        result = order.refunds.create(
          :transaction_id   => order.payment_transaction_number, 
          :amount           => gc_amount, 
          :user_id          => User.current_user.id, 
          :response_data    => "giftcard_refund", 
          :message          => "Refunded #{gc_amount.format} to gift card #{card.giftcard_number}", 
          :success          => true)
      
        gc_amount = Money.new(0) #set amount to 0 because we put it all back on this card
        
      end #end if on giftcard amount
      
    end #end loop over giftcards
    
    
    return result if amount.cents == 0 #return here IF we have no  amount to refund it was all GC
    
    
    #create a money object.  
    amount_to_refund = amount #money
    
    
    #if pmnt type is credit, we can add else conditions for other payment types
    if order.payment_provider_id == Order::PAYMENT_CREDIT_CARD
    
      #sets active merchant into test mode if we aren't in production mode
      ActiveMerchant::Billing::Base.mode = :test if RAILS_ENV != "production"
    
      #create a new gateway to authorize.net
      gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new({
        :login => APP_CONFIG['authorize_net']['login_id'].to_s,            #API Login ID
        :password => APP_CONFIG['authorize_net']['transaction_key'].to_s   #Transaction Key
      })
    
      begin
        cc_num = Security::SecurityManager.decrypt(order.payment_transaction_data)
      rescue Exception => e
        raise "Decryption Error: #{e.message}"
      end
      
      
      options = {
        :card_number => cc_num, 
        :order_id => "#{order.order_id}", 
        :description => "Full Refund"
      }

      #try to void the transaction
      void_response = gateway.void(order.payment_transaction_number)
      
      #if the void was a success
      if void_response.success?
      
        #make a refund object from the void response data
        response_data  = String.new
        response_data += %(response_code: #{void_response.params['response_code'].to_s}, )
        response_data += %(response_reason_code: #{void_response.params['response_reason_code'].to_s})
        result = order.refunds.create(
          :transaction_id   => order.payment_transaction_number, 
          :amount           => amount, 
          :user_id          => User.current_user.id, 
          :response_data    => response_data, 
          :message          => void_response.message, 
          :success          => true)
        
      
      else #the void didn't go through
        
        #try a credit 
        credit_response = gateway.credit(amount_to_refund, order.payment_transaction_number, options)
        
        #if the credit was a success
        if credit_response.success?
          
          #make a refund object from the credit response data
          response_data  = String.new
          response_data += %(response_code: #{credit_response.params['response_code'].to_s}, )
          response_data += %(response_reason_code: #{credit_response.params['response_reason_code'].to_s})
          result = order.refunds.create(
            :transaction_id   => order.payment_transaction_number, 
            :amount           => amount, 
            :user_id          => User.current_user.id, 
            :response_data    => response_data, 
            :message          => credit_response.message, 
            :success          => true)
          
        else
          
          #ok, so now the void and credit both failed
          #make a refund object from the failed void and credit response data
          void_response_data  = String.new
          void_response_data += %(response_code: #{void_response.params['response_code'].to_s}, )
          void_response_data += %(response_reason_code: #{void_response.params['response_reason_code'].to_s})
          result = order.refunds.create(
            :transaction_id   => order.payment_transaction_number, 
            :amount           => amount, 
            :user_id          => User.current_user.id, 
            :response_data    => void_response_data, 
            :message          => void_response.message, 
            :success          => false)
          
          credit_response_data  = String.new
          credit_response_data += %(response_code: #{credit_response.params['response_code'].to_s}, )
          credit_response_data += %(response_reason_code: #{credit_response.params['response_reason_code'].to_s})
          result = order.refunds.create(
            :transaction_id   => order.payment_transaction_number, 
            :amount           => amount, 
            :user_id          => User.current_user.id, 
            :response_data    => credit_response_data, 
            :message          => credit_response.message, 
            :success          => false)
          
        end #end if credit was a success
        
      end #end if void was a success

      
    end #end if on payment_type
    
    return result

  end #end self.make_refund
  
  
  ##
  # method to make a partial refund on a order that has already been setteled.
  # @param Order order - order which credit should be given on
  # @param Money amount - amount of credit
  # @param String message - any message to include in the credit notes
  # @return Refund - a refund object
  ##
  def self.make_partial_refund(order, amount, message='')
  
    #create a money object.  
    #amount_to_refund = Money.new((amount.to_f*100).to_i) # US dollars
    amount_to_refund = amount #money object
    
    #if pmnt type is credit, we can add else conditions for other payment types
    if order.payment_provider_id == Order::PAYMENT_CREDIT_CARD
    
      #sets active merchant into test mode if we aren't in production mode
      ActiveMerchant::Billing::Base.mode = :test if RAILS_ENV != "production"
    
      #create a new gateway to authorize.net
      gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new({
        :login => APP_CONFIG['authorize_net']['login_id'].to_s,            #API Login ID
        :password => APP_CONFIG['authorize_net']['transaction_key'].to_s   #Transaction Key
      })
    
      begin
        cc_num = Security::SecurityManager.decrypt(order.payment_transaction_data)
      rescue Exception => e
        raise "Decryption Error: #{e.message}"
      end
      
      options = {
        :card_number => cc_num, 
        :order_id => "#{order.order_id}", 
        :description => "Partial Refund"
      }

      #try a credit 
      credit_response = gateway.credit(amount_to_refund, order.payment_transaction_number, options)
    
      #if the credit was a success
      if credit_response.success?
        
        #make a refund object from the credit response data
        response_data  = String.new
        response_data += %(response_code: #{credit_response.params['response_code'].to_s}, )
        response_data += %(response_reason_code: #{credit_response.params['response_reason_code'].to_s})
        credit_message = message.blank? ? credit_response.message : credit_response.message + '; ' + message
        result = order.refunds.create(
          :transaction_id   => order.payment_transaction_number, 
          :amount           => amount, 
          :user_id          => User.current_user.id, 
          :response_data    => response_data, 
          :message          => credit_message, 
          :success          => true)
        
      else
        
        #make a refund object from the failed credit response data
        response_data  = String.new
        response_data += %(response_code: #{credit_response.params['response_code'].to_s}, )
        response_data += %(response_reason_code: #{credit_response.params['response_reason_code'].to_s})
        credit_message = message.blank? ? credit_response.message : credit_response.message + '; ' + message
        result = order.refunds.create(
          :transaction_id   => order.payment_transaction_number, 
          :amount           => amount, 
          :user_id          => User.current_user.id, 
          :response_data    => response_data, 
          :message          => credit_message, 
          :success          => false)
        
      end #end if credit was a success
      

      
    end #end if on payment_type
    
    
    return result
    
  end #end method self.make_partial_refund(order, amount)
  
  
end #end class