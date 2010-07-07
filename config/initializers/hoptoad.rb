HoptoadNotifier.configure do |config|
  config.api_key = '14c40633659eff3ead0eeec035db7bbe'
  config.ignore << REXML::ParseException
  config.ignore << ActionController::UnknownHttpMethod
end