APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/appconfig.yml")[RAILS_ENV]

PRODUCT_IMG_STORE  = File.expand_path("#{RAILS_ROOT}/#{APP_CONFIG['filesystem']['local_images_path']}")
PRODUCT_FILE_STORE = File.expand_path("#{RAILS_ROOT}/#{APP_CONFIG['filesystem']['local_files_path']}")
SHIP_LABELS_STORE  = File.expand_path("#{RAILS_ROOT}/#{APP_CONFIG['filesystem']['local_labels_path']}")

WEB_LABEL_REPOSITORY = "#{APP_CONFIG['filesystem']['web_labels_path']}"
WEB_FILE_REPOSITORY  = "#{APP_CONFIG['filesystem']['web_files_path']}"