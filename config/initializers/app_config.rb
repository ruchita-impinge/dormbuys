APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/appconfig.yml")[RAILS_ENV]

if RAILS_ENV == 'production'
  PRODUCT_IMG_STORE  = APP_CONFIG['filesystem']['local_images_path']
  PRODUCT_FILE_STORE = APP_CONFIG['filesystem']['local_files_path']
  SHIP_LABELS_STORE  = APP_CONFIG['filesystem']['local_labels_path']
else
  PRODUCT_IMG_STORE  = File.expand_path("#{RAILS_ROOT}/#{APP_CONFIG['filesystem']['local_images_path']}")
  PRODUCT_FILE_STORE = File.expand_path("#{RAILS_ROOT}/#{APP_CONFIG['filesystem']['local_files_path']}")
  SHIP_LABELS_STORE  = File.expand_path("#{RAILS_ROOT}/#{APP_CONFIG['filesystem']['local_labels_path']}")
end