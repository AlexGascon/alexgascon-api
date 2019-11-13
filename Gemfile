source "https://rubygems.org"

gem "jets", "<= 1.9.30"

gem 'climate_control'
gem "dynamoid"
gem "httparty"
gem 'aws-sdk-cloudwatch'



group :development do
  gem 'rubocop'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'shotgun'
  gem 'rack'
  gem 'puma'
end

group :test do
  gem 'rspec' # rspec test group only or we get the "irb: warn: can't alias context from irb_context warning" when starting jets console
  gem 'launchy'
  gem 'webmock'
end
