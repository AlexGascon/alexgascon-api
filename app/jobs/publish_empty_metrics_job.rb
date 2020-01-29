# frozen_string_literal: true

class PublishEmptyMetricsJob < ApplicationJob
  def publish
    cloudwatch = AwsServices::CloudwatchWrapper.new

    empty_basal = Health::Injection.new(injection_type: 'basal', units: 0)
    cloudwatch.publish_injection(empty_basal)

    empty_bolus = Health::Injection.new(injection_type: 'bolus', units: 0)
    cloudwatch.publish_injection(empty_bolus)
  end
end
