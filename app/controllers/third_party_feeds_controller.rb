class ThirdPartyFeedsController < ApplicationController
  
  def data_feeds
    if params[:id]
      feed_id = params[:id].to_i
      
      # webgains CSV id=1
      if feed_id == 1
      
        @products = Product.find(:all, :conditions => {:visible => true})
     
        output = %("Name","Deeplink","Category","Price","ProductId","description","image_URL","thumbnail_image_URL","delivery_time","delivery_cost","related_product_ids"\n)

        for product in @products
            name = product.product_name
            deeplink = "http://www.dormbuys.com#{product.default_front_url}"
            category = product.subcategories.collect{|sub| sub.category.name}.first
            price = product.retail_price.to_s
            product_id = product.id
            description = product.product_overview.gsub(/(\r\n|\r|\n|\t)/s, "").gsub(/”/, '"').gsub(/"/, '""')
            begin
              image_url = product.product_image(:main)
            rescue
              image_url = "http://www.dormbuys.com"
            end
            begin
              thumbnail_image_URL = product.product_image(:thumb)
            rescue
              thumbnail_image_URL = "http://www.dormbuys.com"
            end
            delivery_time = "varies by location"
            delivery_cost = "varies by location"
            related_product_ids = product.recommended_products.collect{|p| p.id}.join("|")
          
            output += %("#{name}","#{deeplink}","#{category}","#{price}","#{product_id}","#{description}","#{image_url}","#{thumbnail_image_URL}","#{delivery_time}","#{delivery_cost}","#{related_product_ids}"\n)
        end

        headers['Content-Type'] = "application/csv" 
        headers['Content-Disposition'] = "attachment; filename=\"current_products.csv\""
        headers['Cache-Control'] = ''
        render :text => output
        
      #packstream order to label feed id=2
      elsif feed_id == 2
        
        order = Order.find_by_order_id(params[:order_id])
        labelXML = ""
        for slabel in order.shipping_labels
          labelXML += %(<label>)
            labelXML += %(<trackingNumber>#{slabel.tracking_number}</trackingNumber>)
            labelXML += %(<labelUrl>http://www.dormbuys.com#{slabel.graphic_url}</labelUrl>)
          labelXML += %(</label>)
        end
        
        out = <<-EOXML
        <orderLabelInfo>
          <orderId>#{order.order_id}</orderId>
          <shippingLables>
            #{labelXML}
          </shippingLables>
        </orderLabelInfo>
        EOXML
        
        render :xml => out
        
      end #end if feed_id == X
      
    else
      redirect_to root_path
    end
    
  end #end method data_feeds
  
end
