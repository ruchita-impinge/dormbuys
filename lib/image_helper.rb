class ImageHelper
  
  def self.reprocess_images_in_background
    ImageHelper.send_later(:reprocess_images)
  end #end method self.reprocess_images_in_background
  
  
  def self.reprocess_images
    ImageHelper.reprocess_products
    ImageHelper.reprocess_variations
    ImageHelper.reprocess_additional_images
    
    # send an email (just delivery of email indicates completion)
    # email content is meaningless
    Notifier.deliver_forgot_password("brian@parkersmithsoftware.com", "image_reproc_is_done")
  end #end method self.reprocess_images
  
  
  def self.reprocess_products
    products = Product.all
    products.each do |p|
      if p.product_image.file?
        p.product_image.reprocess!
        p.skip_all_callbacks = true
        p.save(false)
        puts "Reprocessed [PRODUCT] id: #{p.id}, name: #{p.product_name}"
      end
    end
  end #end method self.reprocess_products
  
  
  
  def self.reprocess_variations
    variations = ProductVariation.all
    variations.each do |v|
      if v.image.file?
        v.image.reprocess!
        v.skip_touch
        v.save(false)
        puts "Reprocessed [VARIATION] id: #{v.id}"
      end
    end
  end #end method self.reprocess_variations
  
  
  
  def self.reprocess_additional_images
    additional_imgs = AdditionalProductImage.all
    additional_imgs.each do |ai|
      if ai.image.file?
        ai.image.reprocess!
        ai.save(false)
        puts "Reprocessed [ALT-IMG] id: #{ai.id}"
      end
    end
  end #end method self.reprocess_additional_images
  
  
  
end #end class