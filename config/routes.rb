ActionController::Routing::Routes.draw do |map|

  # map.auto_complete ':controller/:action', 
  #      :requirements => { :action => /auto_complete_for_\S+/ },
  #      :conditions => { :method => :get },
  #      :controller => ':controller',
  #      :action => ':action'

  map.product_auto_complete_product_name '/admin/products/auto_complete_for_product_product_name',
    :conditions => {:method => :get},
    :controller => 'admin/products',
    :action => 'auto_complete_for_product_product_name'

#--------------
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
  map.admin_vendors_search '/admin/vendors/search', :controller => 'admin/vendors', :action => 'search'
  map.admin_giftcard_search '/admin/gift_cards/search', :controller => 'admin/gift_cards', :action => 'search'
  map.admin_coupons_search '/admin/coupons/search', :controller => 'admin/coupons', :action => 'search'
  map.admin_products_search '/admin/products/search', :controller => 'admin/products', :action => 'search'

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'

  map.resource :session

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
  end
  
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"
  

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
    
end
