# frozen_string_literal: true

Aws.config.update(
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS'], ENV['AWS_SECRET'])
)
