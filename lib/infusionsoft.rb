require 'xmlrpc/client'

#class Net::HTTP
#  alias_method :old_initialize, :initialize
#  def initialize(*args)
#    old_initialize(*args)
#    @ssl_context = OpenSSL::SSL::SSLContext.new
#    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
#  end
#end


class InfusionsoftResponse
  def initialize
    @successful = false
  end #end method initialize
  
  def success?
    @successful
  end #end method success?
end



class InfusionsoftResult < InfusionsoftResponse
  def initialize(params)
    @successful = true
    @params = params
  end #end method initialize(params)
  
  def data
    @params
  end #end method data
end



class InfusionsoftError < InfusionsoftResponse
  def initialize(params)
    @successful = false
    @faultCode    = params.faultCode
    @faultString  = params.faultString
  end #end method initialize(params)
  
  def code
    @faultCode
  end #end method code
  
  def message
    @faultString
  end #end method message
end



class Infusionsoft
  
  ENCRYPTION_KEY = "afded28471fb672d0cacb4b0b1417f9f"
  SERVICE_URL = "https://dormbuys.infusionsoft.com/api/xmlrpc"
  
  TAG_PROSPECT                      = 92
  TAG_CUSTOMER                      = 93
  TAG_NEWSLETTER_SUBSCRIBER         = 91
  TAG_10_PERCENT_COUPON             = 98
  TAG_P_PARENT                      = 100
  TAG_P_COLLEGE_STUDENT             = 102
  TAG_P_HIGH_SCHOOL_STUDENT         = 104
  TAG_P_OTHER                       = 106
  TAG_C_PARENT                      = 158
  TAG_C_COLLEGE_STUDENT             = 156
  TAG_C_HIGH_SCHOOL_STUDENT         = 160
  TAG_C_OTHER                       = 162
  TAG_DAILY_DEAL                    = 174
  
  SEQUENCE_PROSPECT_TO_CUSTOMER   = 166
  
  
  def initialize
    @server = XMLRPC::Client.new2(SERVICE_URL)
  end #end method initialize
  
  
  ##
  # Function to load up a Contact by ID and return the given fields as a hash. If no fields are requested
  # the following is default: FirstName, LastName, Email, Id.  If nothing was found or there was an error
  # nil is returned.
  ##
  def load(id, return_fields=[])
    result = api_load(id, return_fields)
    if result.success?
      result.data
    else
      nil
    end
  end #end method load(id)
  
  
  ##
  # Function to find a Contact's ID from the given data.  Only the first match will be returned.
  # if there is NO match, nil will be returned.
  ##
  def find(first_name="", last_name="", email="", exact_match=true)
    result = api_find_contact(first_name, last_name, email, exact_match)
    if result.success?
      return nil if result.data.first.nil?
      result.data.first["Id"]
    else
      nil
    end
  end #end method find(first_name="", last_name="", email="")
  
  
  ##
  # tags the given ID as a customer
  ##
  def tag_as_customer(id)
    result = api_add_to_group(id, TAG_CUSTOMER)
    if result.success?
      true
    else
      false
    end
  end #end method tag_as_customer(id)
  
  
  ##
  # tags the given ID as a prospect
  ##
  def tag_as_prospect(id)
    result = api_add_to_group(id, TAG_PROSPECT)
    if result.success?
      true
    else
      false
    end
  end #end method tag_as_prospect(id)
  
  
  
  def add_contact(first_name, last_name, email)
    result = api_add_contact({"FirstName" => first_name, "LastName" => last_name, "Email" => email})
    if result.success?
      result.data
    else
      nil
    end
  end #end method add_contact
  
  
  
  def get_who_am_i_constant(form_value)
    get_who_am_i_constant_customer(form_value)
  end #end method get_who_am_i_constant(form_value)
  
  
  def get_who_am_i_constant_customer(form_value)
    case form_value.downcase
      when /college student/
        TAG_C_COLLEGE_STUDENT
      when /high school student/
        TAG_C_HIGH_SCHOOL_STUDENT
      when /parent/
        TAG_C_PARENT
      when /other/
        TAG_C_OTHER
      else
        TAG_C_OTHER
    end
  end #end method get_who_am_i_constant_customer(form_value)
  
  
  def get_who_am_i_constant_prospect(form_value)
    case form_value.downcase
      when /college student/
        TAG_P_COLLEGE_STUDENT
      when /high school student/
        TAG_P_HIGH_SCHOOL_STUDENT
      when /parent/
        TAG_P_PARENT
      when /other/
        TAG_P_OTHER
      else
        TAG_P_OTHER
    end
  end #end method get_who_ami_constant_prospect(form_value)
  
  
  
####[ Custom functionality implementation ]####

  def find_or_create(first_name, last_name, email)
    id = find(first_name, last_name, email)
    if id
      return id
    else
      new_id = add_contact(first_name, last_name, email)
      if new_id
        return new_id
      else
        return nil
      end
    end
  end #end method find_or_create(first_name, last_name, email)


  ##
  # Create a new customer & get ID or retrieve existing customer's ID.  Then run prospect to customer sequence.
  ##
  def find_or_create_then_p_to_c(first_name, last_name, email, who_am_i=nil)
    id = find(first_name, last_name, email)
    if id
      result = api_run_action_sequence(id, SEQUENCE_PROSPECT_TO_CUSTOMER)
      
      if result.success? && who_am_i
        tag_result = api_add_to_group(id, get_who_am_i_constant(who_am_i))
        return (tag_result.success? ? true : false)
      else
        return (result.success? ? true : false)
      end
      
    else
      new_id = add_contact(first_name, last_name, email)
      if new_id
        result = api_run_action_sequence(new_id, SEQUENCE_PROSPECT_TO_CUSTOMER)
        
        if result.success? && who_am_i
          tag_result = api_add_to_group(new_id, get_who_am_i_constant(who_am_i))
          return (tag_result.success? ? true : false)
        else
          return (result.success? ? true : false)
        end
        
      else
        return false
      end
    end
  end #end
  
  


  ##
  # Load the requested ID returning the given fields
  ##
  def api_load(id, return_fields=[])
    
    return_fields = ["Id", "FirstName", "LastName", "Email"] if return_fields.size == 0
    
    ok, param = @server.call2("DataService.load", ENCRYPTION_KEY, "Contact", id, return_fields)
    if ok then
      InfusionsoftResult.new(param)
    else
      InfusionsoftError.new(param)
    end
  end #end method load(id)
  
  

  ##
  # Find a contact using DataService.query api looking up the first_name, last_name and email 
  ##
  def api_find_contact(first_name, last_name, email, exact = true)
    
    if exact
      contact = {"FirstName" => first_name, "LastName" => last_name, "Email" => email}
    else
      contact = {"FirstName" => "%#{first_name}%", "LastName" => "%#{last_name}%", "Email" => "%#{email}%"}
    end

    
    ok, param = @server.call2("DataService.query", ENCRYPTION_KEY, "Contact", 10, 0, contact, ["Id", "FirstName", "LastName", "Email"])
    if ok then
      InfusionsoftResult.new(param)
    else
      InfusionsoftError.new(param)
    end
    
  end #end method find_contact(first_name, last_name, email)
  
  
  
  ##
  # Add the given id to the given group
  ##
  def api_add_to_group(id, tag_id)
    ok, param = @server.call2("ContactService.addToGroup", ENCRYPTION_KEY, id, tag_id)
    if ok then
      InfusionsoftResult.new(param)
    else
      InfusionsoftError.new(param)
    end
  end #end method api_add_to_group(id, tag_id)
  
  
  
  ##
  # Run the given action sequence on the given id
  ##
  def api_run_action_sequence(contact_id, sequence_id)
    ok, param = @server.call2("ContactService.runActionSequence", ENCRYPTION_KEY, contact_id, sequence_id)
    if ok then
      InfusionsoftResult.new(param)
    else
      InfusionsoftError.new(param)
    end
  end #end method run_action_sequence(sequence_id, contact_id)
  
  
  
  def api_add_contact(values={})
    ok, param = @server.call2("ContactService.add", ENCRYPTION_KEY, values)
    if ok then
      InfusionsoftResult.new(param)
    else
      InfusionsoftError.new(param)
    end
  end #end method add_contact(values={})
  
  
end #end class