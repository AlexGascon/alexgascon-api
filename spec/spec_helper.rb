ENV["TEST"] = "1"
ENV["JETS_ENV"] ||= "test"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentails
ENV['HOME'] = "spec/fixtures/home"

require "byebug"
require "fileutils"
require "jets"

abort("The Jets environment is running in production mode!") if Jets.env == "production"
Jets.boot

require "jets/spec_helpers"

Dir[Jets.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |c|
  c.before(:each) do
    DynamoidReset.all
  end
end
