source 'https://rubygems.org'

gem 'jets'

gem 'airrecord'
gem 'annotate'
gem 'aws-sdk-cloudwatch'
gem 'aws-sdk-s3'
gem 'climate_control'
gem 'dexcom', '~> 0.2.2'
gem 'dynamoid'
gem 'factory_bot'
gem 'httparty'
gem 'parallel'
gem 'pg'
gem 'telegram-bot-ruby'
gem 'ynab'

group :development do
  gem 'rubocop'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'awesome_print'
  gem 'byebug', '= 11.0.1', platforms: %i[mri mingw x64_mingw] # 2020/06/14 Higher versions not yet available on Lambdagems
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'puma', '4.3.5' # 2020/06/14 Higher versions not yet available on Lambdagems
  gem 'rack'
  gem 'shotgun'
end

group :test do
  gem 'launchy'
  gem 'rspec'
  gem 'webmock'
end
