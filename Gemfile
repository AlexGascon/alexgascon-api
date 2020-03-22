source 'https://rubygems.org'

gem 'jets', '<= 1.9.30'

gem 'airrecord'
gem 'aws-sdk-cloudwatch'
gem 'aws-sdk-s3'
gem 'climate_control'
gem 'dynamoid'
gem 'httparty'
gem 'telegram-bot-ruby'
gem 'ynab'

group :development do
  gem 'rubocop'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'awesome_print'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'puma'
  gem 'rack'
  gem 'shotgun'
end

group :test do
  gem 'launchy'
  gem 'rspec' # rspec test group only or we get the "irb: warn: can't alias context from irb_context warning" when starting jets console
  gem 'webmock'
end
