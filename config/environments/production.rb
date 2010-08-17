# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
#config.action_controller.asset_host = "http://assets.example.com/myassets"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

ENV["RAILS_ASSET_ID"] = '201008171700'


# CACHE KEYS IN PLAY
#
# home_page_1
# home_page_2
# front_large_banner_1
# front_large_banner_2
# front_large_banner_3
# @category
# @subcategory
# [@subcategory, "page_#{params[:page].to_i}"]
# @product


memcache_options = {
  :c_threshold => 10000,
  :compression => true,
  :debug => false,
  :namespace => 'dormbuys',
  :readonly => false,
  :urlencode => false

}

require 'memcache' 
config.cache_store = :mem_cache_store, 'localhost:11211', memcache_options

# this is where you deal with passenger's forking
begin
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     if forked
       
       # We're in smart spawning mode, so...
       # Close duplicated memcached connections - they will open themselves
       Rails.cache.instance_variable_get(:@data).reset
       
     end
   end
# In case you're not running under Passenger (i.e. devmode with mongrel)
rescue NameError => error
end