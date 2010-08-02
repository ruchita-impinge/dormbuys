module OrderHelper
  
  
  def get_note_icons(order)
		images = ""
		images += image_tag('/images/css/lorry.png')          if order.dropship_only?
		images += image_tag('/images/css/email.png')          if order.has_usps?
		images += image_tag('/images/css/exclamation.png')    if order.invalid_address_alert?
		images += image_tag('/images/css/package_green.png')  if order.is_processed?
		images += image_tag('/images/css/comment.png')        if order.has_comments?
		images
  end #end method get_note_icons(order)
  
  
  
  def order_row_css(order)
    css_class = ""
  	css_class = "order_status_unsent_dropship"      if order.unsent_dropships?
  	css_class = "order_status_ds_sent_waiting_ship" unless order.unsent_dropships?
  	css_class = "order_status_dorm_ship"            if order.dorm_ship?
  	css_class = "order_status_complete"             if order.shipped_complete?
  	css_class = "order_status_canceled"             if order.canceled?
  	css_class
  end #end method order_row_css(order)
  
  
  
  def print_billing_address_html(order)
    out = <<-EO_HTML
      #{order.billing_first_name} #{order.billing_last_name}<br />
      #{order.billing_address}<br />
      #{order.billing_address2.blank? ? '' : order.billing_address2 + '<br />'}
      #{order.billing_city}, #{order.billing_state.abbreviation} #{order.billing_zipcode}<br />
      #{order.billing_country.country_name}<br />
      #{order.billing_phone}
    EO_HTML
  end #end method print_billing_address_html(order)
  
  
  
  def print_shipping_address_html(order)
    if order.user_profile_type_id == Order::ADDRESS_DORM
      out = <<-EO_HTML
        #{order.shipping_first_name} #{order.shipping_last_name}<br />
        <span class="field_error">#{order.dorm_ship_college_name}</span><br />
        <span class="field_error">#{order.shipping_address}</span><br />
        #{order.shipping_address2.blank? ? '' : (order.dorm_ship_not_part ? '' : '<span class="field_error">' + order.shipping_address2 + '</span><br />')}
        <span class="field_error">#{order.shipping_city}, #{order.shipping_state.abbreviation} #{order.shipping_zipcode}</span><br />
        <span class="field_error">#{order.shipping_country.country_name}</span><br />
        <span class="field_error">#{order.shipping_phone}</span><br />
        <span class="field_error">Ship: #{order.when_to_dorm_ship}</span><br />
        #{order.dorm_ship_not_assigned ? '<span class="field_error"><b>Note:</b> Customer has not been assigned a box / building / or room number.  They need to be contacted to get this information.</span>' : ''}
      EO_HTML
    else
      out = <<-EO_HTML
        #{order.shipping_first_name} #{order.shipping_last_name}<br />
        #{order.shipping_address}<br />
        #{order.shipping_address2.blank? ? '' : order.shipping_address2 + '<br />'}
        #{order.shipping_city}, #{order.shipping_state.abbreviation} #{order.shipping_zipcode}<br />
        #{order.shipping_country.country_name}<br />
        #{order.shipping_phone}
      EO_HTML
    end
    out
  end #end method print_shipping_address_html(order)


  
end #end module