class Notifier < ActionMailer::Base

  def customer_order_notification(order)
    subject        "Thanks for your order at Dormbuys.com"
    body           :order => order
    recipients     RAILS_ENV == 'development' ? APP_CONFIG['dev_email'] : order.email
    bcc            RAILS_ENV == 'production' ? APP_CONFIG['supervisor_email'] : nil
    from           'Dormbuys.com <support@dormbuys.com>'
    sent_on        Time.now
    content_type   = "text/html"
    headers        = {}
  end #end method customer_order_notification


  def vendor_dropship_notification(user, vendor, order)
    subject        "New Drop Ship Order: Dormbuys.com"
    code           = Security::SecurityManager.simple_encrypt("#{vendor.id}-#{order.id}")
    body           :vendor => vendor, :order => order, :url => "http://#{APP_CONFIG['base_url']}/vendors/remote_packing_list?code=#{code}"
    recipients     RAILS_ENV == 'development' ? APP_CONFIG['dev_email'] : user.email
    from           'Dormbuys.com <support@dormbuys.com>'
    sent_on        Time.now
    content_type   = "text/html"
    headers        = {}
  end #end method vendor_dropship_notification
  

  def forgot_password(to, pass)
    subject        "Your Dormbuys.com password has been reset ..."
    body           :pass => pass
    recipients     RAILS_ENV == 'development' ? APP_CONFIG['dev_email'] : to
    from           'Dormbuys.com <support@dormbuys.com>'
    sent_on        Time.now
    content_type   = "text/html"
    headers        = {}
  end #end method forgot_password(to, pass)
  
  
  def contact(name, email, subject, message)
    subject          "Contact message from Dormbuys.com ..."
    body             :name => name, :email => email, :subject => subject, :message => message
    recipients       RAILS_ENV == 'development' ? APP_CONFIG['dev_email'] : APP_CONFIG['contact_email'].to_s
    from             'Dormbuys.com <support@dormbuys.com>'
    sent_on          Time.now
    content_type     = "text/html"
    headers          = {}
  end #end method contact(name, email, subject, message)
  
  
  def order_canceled(order)
    subject        "Your Dormbuys.com order has been canceled ..."
    body           :order => order
    recipients     RAILS_ENV == 'development' ? APP_CONFIG['dev_email'] : order.email
    from           'Dormbuys.com <support@dormbuys.com>'
    sent_on        Time.now
    content_type   = "text/html"
    headers        = {}
  end #end method order_canceled(order)
  
  
  def updated_tracking(order)
    subject        "Your Dormbuys.com order has been updated ..."
    body           :order => order
    recipients     RAILS_ENV == 'development' ? APP_CONFIG['dev_email'] : order.email
    from           'Dormbuys.com <support@dormbuys.com>'
    sent_on        Time.now
    content_type   = "text/html"
    headers        = {}
  end #end method updated_tracking(order)
  
  
  def zero_inventory(product_variation)
    subject        "Uh-Oh, #{product_variation.full_title}, qty on hand is: #{product_variation.qty_on_hand}"
    body           :product_name => product_variation.full_title, :qty_on_hand => product_variation.qty_on_hand, :edit_url => "http://#{APP_CONFIG['base_url']}/admin/products/edit/#{product_variation.product.id}"
    recipients     RAILS_ENV == 'development' ? APP_CONFIG['dev_email'] : APP_CONFIG['warehouse_admin_email']
    from           'Dormbuys.com <support@dormbuys.com>'
    sent_on        Time.now
    content_type   = "text/html"
    headers        = {}
  end #end method zero_inventory(product_variation)
  

end
