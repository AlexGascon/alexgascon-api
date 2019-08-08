Jets.application.configure do
  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  # Docs: http://rubyonjets.com/docs/email-sending/
  config.action_mailer.delivery_method = :test
end

Dynamoid.configure do |config|
  config.namespace = "#{Jets.application.config.project_name}_#{Jets.env}"
  config.endpoint = 'http://localhost:6000'
  config.read_capacity = 1
  config.write_capacity = 1
end