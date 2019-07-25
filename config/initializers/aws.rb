# frozen_string_literal: true

Aws.config.update({
  region: 'eu-west-1',
  credentials: Aws::Credentials.new(
    ENV['AWS_ACCESS_KEY_ID'],
    ENV['AWS_SECRET_ACCESS_KEY']
  )
})