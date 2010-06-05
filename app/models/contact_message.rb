class ContactMessage < ActiveRecord::Base

  include Authentication
  
  attr_accessor :spam_question, :spam_answer
  
  validates_presence_of :name, :email, :subject, :message
  
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  def validate
    errors.add(:spam_answer, "math must add up correctly") if self.spam_question != self.spam_answer
  end #end method validate
    
end
