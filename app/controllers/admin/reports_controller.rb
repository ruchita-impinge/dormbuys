class Admin::ReportsController < Admin::AdminController
  
  
  def inventory_count_list
    
    @file_name = "inventory_count_inv_products_only"
    @variations = ProductVariation.find(:all, :include => [:product])
    @variations.reject!{|x| x if x.product.blank?}
    @variations.reject! {|x| x.product.drop_ship}
    
    @variations.sort! {|x,y| x.full_title <=> y.full_title}
    
    #variation.product.subcategories.first.name
    #variation.product.subcategories.first.category.name
    
    headers['Content-Type'] = "application/vnd.ms-excel" 
    headers['Content-Disposition'] = "attachment; filename=\"#{@file_name}.xls\""
    headers['Cache-Control'] = ''
    
    render :layout => false
    
  end #end method inventory_count_list
  
  
  
  def email_list
    @emails = EmailListClient.find(:all).collect(&:email) | DormBucksEmailListClient.find(:all).collect(&:email)
    @users = User.find(:all)
    
    @output = []
    
    @emails.each {|mail| @output << ["","",mail] }
    @users.each {|u| @output << [u.first_name, u.last_name, u.email] }
    
		headers['Content-Type'] = "application/vnd.ms-excel" 
    headers['Content-Disposition'] = 'attachment; filename="email-list-export.xls"'
    headers['Cache-Control'] = ''
    
    render :layout => false
  end #end method email_list
  
  
end #end class