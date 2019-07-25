# frozen_string_literal: true

Dynamoid.configure do |config|
  config.namespace = "#{Jets.application.config.project_name}_#{Jets.env}"
  config.endpoint = ENV['DYNAMOID_ENDPOINT'] if Jets.env == 'test' || Jets.env == 'development'
end
