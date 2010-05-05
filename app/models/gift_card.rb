class GiftCard < ActiveRecord::Base
  
  before_create :set_current_amount
  
  has_and_belongs_to_many :orders
  
  validates_presence_of :giftcard_number, :giftcard_pin
  validates_numericality_of :giftcard_number
  validates_uniqueness_of :giftcard_number, :case_sensitive => false, :message => ' already exists in the system'
  
  composed_of :current_amount, 
    :class_name => "Money", 
    :mapping => %w(int_current_amount cents),
    :converter => Proc.new { |amount| amount.to_money }
  
  composed_of :original_amount, 
    :class_name => "Money", 
    :mapping => %w(int_original_amount cents),
    :converter => Proc.new {|amount| amount.to_money }
  
  #alias
  def current
    current_amount
  end #end method current
  
  def set_current_amount
    self.current_amount = self.original_amount
  end #end method set_current_amount
    
    
  def generate_new_number_and_pin
    generate_new_number
    generate_new_pin
  end #end method generate_new_number_and_pin
  
  
  
  def generate_new_number
  
    num = generate_number(16)
  
    found = GiftCard.find_by_giftcard_number(num)
    until found.blank?
      num = generate_number(16)
      found = GiftCard.find_by_giftcard_number(num)
    end
    
    self.giftcard_number = num
    
  end #end method generate_new_number
  
  
  
  def generate_new_pin
    self.giftcard_pin = generate_number(6)
  end #end method generate_new_pin
  
  
  
  def generate_number(length)

    #chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    chars = ("0".."9").to_a

    output = ""

    #loop upto the specified length adding a random character
    #from the chars array to the output
    1.upto(length) { |i| output << chars[rand(chars.size-1)] }

    output
    
  end #end method generate_number(length)
  
end
