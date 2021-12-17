source 'https://rubygems.org'

# More info on why this version is required:
# https://github.com/boltops-tools/jets/issues/574#issuecomment-880348281
gem 'jets', '>= 3.0.11'

gem 'airrecord'
gem 'annotate'
gem 'aws-sdk-cloudwatch'
gem 'aws-sdk-s3'
gem 'climate_control'
gem 'dexcom', '~> 0.3.0'
gem 'dynamoid'
gem 'factory_bot'
gem 'httparty'
gem 'parallel'
gem 'pg'
gem 'plaid', '~> 14.0.0.beta'
gem 'redis'
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
  gem 'puma', '4.3.9'
  gem 'rack'
  gem 'shotgun'
end

group :test do
  gem 'launchy'
  gem 'rspec'
  gem 'webmock'
end
