ActionController::Routing::Routes.draw do |map|

  # map.auto_complete ':controller/:action', 
  #      :requirements => { :action => /auto_complete_for_\S+/ },
  #      :conditions => { :method => :get },
  #      :controller => ':controller',
  #      :action => ':action'

  map.ddd_auto_complete_product_name '/admin/daily_dorm_deals/auto_complete_for_product_product_name',
    :conditions => {:method => :get},
    :controller => 'admin/daily_dorm_deals',
    :action => 'auto_complete_for_product_product_name'

  map.product_auto_complete_product_name '/admin/products/auto_complete_for_product_product_name',
    :conditions => {:method => :get},
    :controller => 'admin/products',
    :action => 'auto_complete_for_product_product_name'
    
  map.gift_registry_auto_complete_product_name '/admin/gift_registries/auto_complete_for_product_product_name',
    :conditions => {:method => :get},
    :controller => 'admin/gift_registries',
    :action => 'auto_complete_for_product_product_name'
    
  map.wish_list_auto_complete_product_name '/admin/wish_lists/auto_complete_for_product_product_name',
    :conditions => {:method => :get},
    :controller => 'admin/wish_lists',
    :action => 'auto_complete_for_product_product_name'
    
  map.quantity_discount_auto_complete_product_name '/admin/quantity_discounts/auto_complete_for_product_product_name',
    :conditions => {:method => :get},
    :controller => 'admin/quantity_discounts',
    :action => 'auto_complete_for_product_product_name'
    
  map.vendor_auto_complete_user_email '/admin/vendors/auto_complete_for_user_email',
    :conditions => {:method => :get},
    :controller => 'admin/vendors',
    :action => 'auto_complete_for_user_email'

#-------order builder-------
  map.order_auto_complete_product_name '/admin/orders/auto_complete_for_product_product_name',
    :conditions => {:method => :get},
    :controller => 'admin/orders',
    :action => 'auto_complete_for_product_product_name'
  
  map.order_auto_complete_user_email '/admin/orders/auto_complete_for_user_email',
    :conditions => {:method => :get},
    :controller => 'admin/orders',
    :action => 'auto_complete_for_user_email'
  
  map.admin_order_product_staging '/admin/orders/product_staging', :controller => 'admin/orders', :action => 'product_staging'
  map.admin_order_set_user '/admin/orders/set_user', :controller => 'admin/orders', :action => 'set_user'
  map.admin_order_set_coupon '/admin/order/add_coupon', :controller => 'admin/orders', :action => 'add_coupon'
  map.admin_order_set_gift_card '/admin/order/add_gift_card', :controller => 'admin/orders', :action => 'add_gift_card'
  map.admin_order_calc_shipping '/admin/order/calc_shipping', :controller => 'admin/orders', :action => 'calc_shipping'
#--------------

  map.admin_users_search '/admin/users/search', :controller => 'admin/users', :action => 'search'
  map.admin_orders_search '/admin/orders/search', :controller => 'admin/orders', :action => 'search'
  map.process_admin_order '/admin/orders/:id/process', :controller => 'admin/orders', :action => 'edit'
  map.order_processed '/admin/orders/:id/order_processed', :controller => 'admin/orders', :action => 'complete_processing'
  map.cancel_processing '/admin/orders/:id/cancel_processing', :controller => 'admin/orders', :action => 'cancel_processing'
  map.edit_shipping_admin_order '/admin/orders/:id/edit_shipping', :controller => 'admin/orders', :action => 'edit_shipping'
  map.notify_dropship_admin_order '/admin/orders/:id/notify_dropship', :controller => 'admin/orders', :action => 'notify_dropship'
  map.apply_credit_admin_order '/admin/orders/:id/apply_credit', :controller => 'admin/orders', :action => 'apply_credit'
  map.packing_list_admin_order '/admin/orders/:id/packing_list', :controller => 'admin/orders', :action => 'packing_list'
  map.kill_labels_admin_order '/admin/orders/:id/kill_labels', :controller => 'admin/orders', :action => 'kill_labels'
  map.recreate_labels_admin_order '/admin/orders/:id/recreate_labels', :controller => 'admin/orders', :action => 'recreate_labels'
  map.inline_order_list '/admin/orders/inline_order_list', :controller => "admin/orders", :action => "inline_order_list"
  
  map.admin_vendors_search '/admin/vendors/search', :controller => 'admin/vendors', :action => 'search'
  map.admin_giftcard_search '/admin/gift_cards/search', :controller => 'admin/gift_cards', :action => 'search'
  map.admin_coupons_search '/admin/coupons/search', :controller => 'admin/coupons', :action => 'search'
  map.admin_products_search '/admin/products/search', :controller => 'admin/products', :action => 'search'
  map.admin_gift_registries_search '/admin/gift_registries/search', :controller => 'admin/gift_registries', :action => 'search'
  map.admin_wish_lists_search '/admin/wish_lists/search', :controller => 'admin/wish_lists', :action => 'search'

  #HARD CODED URLS
  map.buy_gift_card '/college/grab_a_gift_card', :controller => 'front', :action => 'product', :product_permalink_handle => "dormbuys-branded-gift-card"
  map.main_gift_registry '/college/gift_registry', :controller => 'front', :action => 'registry'
  map.main_registry_search '/college/gift_registry/search', :controller => 'front', :action => 'registry_search'
  map.main_view_registry '/college/gift_registry/view/:id', :controller => "front", :action => "registry_view"
  map.main_registry_add_to_cart '/collect/gift_registry/:id/add_to_cart', :controller => "front", :action => "registry_add_to_cart"
  
  # Search URL
  map.product_search '/search', :controller => "front", :action => "search"


  # Product, Cat & Subcat URLs
  map.front_product '/college/:category_permalink_handle/:subcategory_permalink_handle/:product_permalink_handle', 
    :controller => 'front', :action => 'product'
    
  map.front_subcategory '/college/:category_permalink_handle/:subcategory_permalink_handle',
    :controller => 'front', :action => 'subcategory'
    
  map.front_category '/college/:category_permalink_handle',
    :controller => 'front', :action => 'category'

  
  #cart urls
  map.cart '/cart', :controller => 'cart', :action => 'index'
  map.add_to_cart '/cart/add', :controller => 'cart', :action => 'add'
  map.update_cart '/cart/update/:cart_item_id', :controller => 'cart', :action => 'update'
  map.remove_from_cart '/cart/remove/:cart_item_id', :controller => 'cart', :action => 'remove'
  map.cart_add_coupon '/cart/add_coupon', :controller => 'cart', :action => 'add_coupon'
  map.cart_login '/cart/login', :controller => 'cart', :action => 'login'
  map.cart_submit_login '/cart/submit_login', :controller => 'cart', :action => 'submit_login'
  map.cart_user_signup '/cart/user_signup', :controller => 'cart', :action => 'user_signup'
  map.cart_billing_shipping '/cart/billing_shipping', :controller => 'cart', :action => 'billing_shipping'
  map.cart_save_billing_shipping '/cart/save_billing_shipping', :controller => 'cart', :action => 'save_billing_shipping'
  map.cart_review '/cart/review', :controller => 'cart', :action => 'review'
  map.cart_confirm '/cart/confirm', :controller => 'cart', :action => 'confirm'
  map.cart_print '/cart/print', :controller => 'cart', :action => 'print'
  map.cart_add_wish_list_item "/cart/add_wish_list_item/:wish_list_item_id", :controller => "cart", :action => "add_wish_list_item"

  #static page urls
  map.affiliates '/affiliates', :controller => 'front', :action => 'affiliates'
  map.links '/links', :controller => 'front', :action => 'links'
  map.news '/news', :controller => 'front', :action => 'news'
  map.privacy_policy '/privacy', :controller => 'front', :action => 'privacy'
  map.blog '/2east', :controller => 'front', :action => 'blog'
  map.twitter '/twitter', :controller => 'front', :action => 'twitter'
  map.facebook '/facebook', :controller => 'front', :action => 'facebook'
  map.contact '/contact', :controller => 'front', :action => 'contact'
  map.contact_submit '/contact_submit', :controller => 'front', :action => 'contact_submit'
  map.returns '/returns', :controller => 'front', :action => 'returns'
  map.scholarships '/scholarships', :controller => 'front', :action => 'scholarships'
  map.security '/security', :controller => 'front', :action => 'security'
  map.shipping '/shipping', :controller => 'front', :action => 'shipping'
  map.faq '/faq', :controller => 'front', :action => 'faq'
  map.email_list_signup '/email_list_signup', :controller => 'front', :action => 'email_list_signup'
  map.data_feeds '/shop/data_feeds/:id', :controller => 'third_party_feeds', :action => 'data_feeds'
  
  #learn_more URLS
  map.learn_not_assigned '/learn_more/not_assigned', :controller => "learn_more", :action =>"not_assigned"
  map.learn_secure_shopping '/learn_more/secure_shopping', :controller => "learn_more", :action =>"secure_shopping"
  map.learn_ship_date '/learn_more/ship_date', :controller => "learn_more", :action =>"ship_date"
  map.learn_vcode '/learn_more/vcode', :controller => "learn_more", :action =>"vcode"
  map.learn_check_giftcard '/learn_more/check_giftcard', :controller => "learn_more", :action =>"check_giftcard"
  
  #account urls
  map.account '/account', :controller => 'account', :action => 'index'
  map.account_login '/account/login', :controller => 'account', :action => 'login'
  map.account_submit_login '/account/submit_login', :controller => 'account', :action => 'submit_login'
  map.account_logout '/account/logout', :controller => 'account', :action => 'logout'
  map.account_user_signup '/account/user_signup', :controller => 'account', :action => 'user_signup'
  map.account_gift_card '/account/gift_card', :controller => 'account', :action => 'gift_card'
  map.account_gift_card_submit '/account/gift_card_submit', :controller => 'account', :action => 'gift_card_submit'
  map.account_password '/account/password', :controller => 'account', :action => 'password'
  map.account_update_password '/account/update_password', :controller => 'account', :action => 'update_password'
  map.account_email '/account/email', :controller => 'account', :action => 'email'
  map.account_email_edit '/account/email_edit', :controller => 'account', :action => 'email_edit'
  map.account_email_subscribe '/account/email_subscribe', :controller => 'account', :action => 'email_subscribe'
  map.account_billing '/account/billing', :controller => 'account', :action => 'billing'
  map.account_billing_edit '/account/billing_edit', :controller => 'account', :action => 'billing_edit'
  map.account_billing_update '/account/billing_update', :controller => 'account', :action => 'billing_update'
  map.account_orders '/account/orders', :controller => 'account', :action => 'orders'
  map.account_view_order '/account/order/:order_id', :controller => 'account', :action => 'view_order'
  map.account_view_order_invoice '/account/order_invoice/:order_id', :controller => 'account', :action => 'order_invoice'
  map.account_all_orders '/account/all_orders', :controller => 'account', :action => 'all_orders'
  map.account_wish_list '/account/wish_list', :controller => 'account', :action => 'wish_list'
  map.account_update_wish_list '/account/update_wish_list', :controller => 'account', :action => 'update_wish_list'
  
  map.account_gift_registries '/account/gift_registries', :controller => 'account', :action => 'gift_registries'
  map.account_select_registry '/account/gift_registries/add_to', :controller => 'account', :action => 'select_registry_to_add_to'
  map.account_add_to_registry '/account/gift_registries/add_to/:id', :controller => 'account', :action => 'add_to_registry'
  map.account_new_gift_registry '/account/gift_registry/new', :controller => 'account', :action => 'new_gift_registry'
  map.account_create_gift_registry '/account/gift_registry/create', :controller => 'account', :action => 'create_gift_registry'
  map.account_edit_gift_registry '/account/gift_registry/:id/edit', :controller => 'account', :action => 'edit_gift_registry'
  map.account_update_gift_registry '/account/gift_registry/:id/update', :controller => 'account', :action => 'update_gift_registry'
  map.account_destroy_gift_registry '/account/gift_registry/:id/destroy', :controller => 'account', :action => 'destroy_gift_registry'
  map.account_add_registry_name '/account/gift_registry/add_registry_name', :controller => 'account', :action => 'add_registry_name'
  map.account_view_gift_registry '/account/gift_registry/:id', :controller => 'account', :action => "view_gift_registry"

  map.forgot_password '/account/forgot_password', :controller => 'account', :action => 'forgot_password'
  map.submit_forgot_password '/account/submit_forgot_password', :controller => 'account', :action => 'submit_forgot_password'

  #map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  #map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'account', :action => 'logout'
  map.login '/login', :controller => 'account', :action => 'login'

  
  
  #SPECIALTY named routes
  map.pie_mask '/pie-mask', :controller => 'promo', :action => 'piemask'
  map.dormbucks '/bucks', :controller => 'promo', :action => 'dormbucks'
  map.check_bucks '/check_dorm_bucks', :controller => 'promo', :action => 'check_dorm_bucks'
  map.sale '/sale', :controller => "front", :action => "subcategory", :subcategory_permalink_handle => "sale"
  map.daily_dorm_deal_email '/dailydeal/email_signup', :controller => 'daily_dorm_deal', :action => 'email_signup'
  map.daily_dorm_deal '/dailydeal', :controller => 'daily_dorm_deal', :action => 'index'
  
  #legacy URLs
  map.legacy_product '/shop/product/:old_site_product_id', :controller => "front", :action => "product"
  map.legacy_category '/shop/category/:old_site_category_id', :controller => "front", :action => "category"
  map.legacy_subcategory '/shop/subcategory/:old_site_subcategory_id', :controller => "front", :action => "subcategory"
  
  #vendor packing list
  map.vendor_packing_list '/vendors/remote_packing_list', :controller => "front", :action => "vendor_packing_list"


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  map.resource :session

  # Sample resource route within a namespace:
  map.namespace :admin do |admin|
    admin.resources :users
    admin.resources :vendors
    admin.resources :warehouses
    admin.resources :brands
    admin.resources :gift_cards
    admin.resources :coupons
    admin.resources :quantity_discounts
    admin.resources :shipping_containers
    admin.resources :shipping_rates_tables
    admin.resources :categories
    admin.resources :subcategories, 
      :collection => {
        :mapper => :get,
        :save_map => :put
      }
    admin.resources :products, 
      :member => {
        :images => :get,
        :options => :get,
        :variations => :get,
        :restricted => :get
      }
    admin.resources :orders
    admin.resources :order_vendors
    admin.resources :wish_lists
    admin.resources :gift_registries
    admin.resources :state_shipping_rates
    admin.resources :daily_dorm_deals
  end
  
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "front", :action => "index"

  # See how all your routes lay out with "rake routes"
  

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
    
end
