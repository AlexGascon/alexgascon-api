Dexcom.configure do |config|
  config.username = ENV['DEXCOM_USERNAME']
  config.password = ENV['DEXCOM_PASSWORD']
  config.outside_usa = true
end