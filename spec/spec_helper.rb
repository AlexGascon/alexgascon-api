# frozen_string_literal: true

ENV['TEST'] = '1'
ENV['JETS_ENV'] ||= 'test'
ENV['JETS_BUILD_NO_INTERNET'] = 'true'
# Ensures AWS APIs are never called. Fixture home folder does not contain ~/.aws/credentials
ENV['HOME'] = File.join(Dir.pwd, 'spec/fixtures/home')

require 'active_support/testing/time_helpers'
require 'byebug'
require 'fileutils'
require 'jets'
require 'rake'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

abort('The Jets environment is running in production mode!') if Jets.env == 'production'
Jets.boot

Jets.load_tasks
Rake::Task['prepare_test_db'].invoke

require 'jets/spec_helpers'

Dir[Jets.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |c|
  c.before(:suite) do
    Time.zone = 'UTC'
  end

  c.before(:each) do
    DynamoidReset.all
  end

  c.include ActiveSupport::Testing::TimeHelpers
end

RSpec::Matchers.define :have_fields do |fields|
  match do |actual|
    fields.each_pair do |field, expected_value|
      actual.send(field) == expected_value
    end
  end
end

RSpec::Matchers.alias_matcher :fields_with_values, :have_fields

def with_modified_env(options, &block)
  ClimateControl.modify(options, &block)
end

def load_json_fixture(path)
  JSON.parse(File.read("spec/fixtures/#{path}.json"))
end

def stub_command(command_class)
  allow(command_class).to receive(:new).and_call_original
  allow_any_instance_of(command_class).to receive(:execute)
end
