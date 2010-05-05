require 'ezcrypto'

class Security::SecurityManager
  
  #encryption method
  def self.encrypt(plain_text) 
    key = EzCrypto::Key.with_password(APP_CONFIG['enc_key'], APP_CONFIG['enc_salt'], :algorithm => 'blowfish')
    key.encrypt(plain_text)
  end #end method encrypt(plain_text)
  
  #decryption method
  def self.decrypt(cypher_text)
    key = EzCrypto::Key.with_password(APP_CONFIG['enc_key'], APP_CONFIG['enc_salt'], :algorithm => 'blowfish')
    key.decrypt(cypher_text)
  end #end method decrypt(cypher_text)
  
  #encrypt text which will be passed in a url
  def self.encrypt_url(plain_text_url)
    CGI.escape(self.encrypt(plain_text_url))
  end #end method self.encrypt_url(plain_text_url)
  
  #decrypt text which was passed in a url
  def self.decrypt_url(cypher_text_url)
    self.decrypt(CGI.unescape(cypher_text_url))
  end #end method self.decrypt_url(cypher_text_url)
  
  #simple method to encrypt some text by just 
  #changing the pattern.  Made really for numbers.
  # ex:  21-2005 => 05201D2
  def self.simple_encrypt(plain_text)
    plain_text.reverse!.gsub!("-","D")
    cypher_arr = []
    0.upto(plain_text.length - 1) do |i|
      cypher_arr << plain_text.slice(i..i+1) if i % 2 == 0
    end
    cypher_arr.each {|el| el.reverse!}
    cypher_arr.join("")
  end #end method self.simple_encrypt(plain_text)
  
  #simple method to decrypt some text by just changing
  #the pattern.  Made really for numbers.
  # ex: 05201D2 => 21-2005
  def self.simple_decrypt(cypher_text)
    plain_arr = []
    0.upto(cypher_text.length - 1) do |i|
      plain_arr << cypher_text.slice(i..i+1) if i % 2 == 0
    end
    plain_arr.each {|el| el.reverse!}
    plain_arr.join("").reverse.gsub("D","-")
  end #end method self.simple_decrypt(cypher_text)
  
end #end class