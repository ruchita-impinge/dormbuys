# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dormbuys_3_0_session',
  :secret      => '8922831eb1e1a99fcc06c937e057022f68ab22d9034ee61bcd94855432c364fb797df2d49982cdae5ce0071e362733323c47dbb1b9812d9136d182cf90718ff9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
