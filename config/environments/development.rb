# frozen_string_literal: true

Jets.application.configure do
  # Example:
  # config.function.memory_size = 1536

  # config.action_mailer.raise_delivery_errors = false
  # Docs: http://rubyonjets.com/docs/email-sending/
end

Dynamoid.configure do |config|
  config.endpoint = 'http://localhost:6000'
  config.read_capacity = 1
  config.write_capacity = 1
end
