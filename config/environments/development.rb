# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true

config.action_controller.perform_caching             = false
#config.action_controller.perform_caching             = true

memcache_options = {
  :c_threshold => 10000,
  :compression => true,
  :debug => false,
  :namespace => 'dormbuys',
  :readonly => false,
  :urlencode => false
}
#config.cache_store = :mem_cache_store
config.cache_store = :mem_cache_store, 'localhost:11211', memcache_options


# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# Enable serving of images, stylesheets, and javascripts from an asset server
#config.action_controller.asset_host = "http://assets.example.com/myassets"

#setup ruby-debug
SCRIPT_LINES__ = {}
require "ruby-debug"
Debugger.start