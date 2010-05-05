require 'ezcrypto'

module SecurityTools
  
  #encryption method
  def encrypt(plain_text) 
    key = EzCrypto::Key.with_password(APP_CONFIG['enc_key'], APP_CONFIG['enc_salt'], :algorithm => 'blowfish')
    key.encrypt(plain_text)
  end #end method encrypt(plain_text)
  
  #decryption method
  def decrypt(cypher_text)
    key = EzCrypto::Key.with_password(APP_CONFIG['enc_key'], APP_CONFIG['enc_salt'], :algorithm => 'blowfish')
    key.decrypt(cypher_text)
  end #end method decrypt(cypher_text)
  
end #end module