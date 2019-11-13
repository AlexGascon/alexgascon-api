# frozen_string_literal: true

module Health
  class CreateInjectionJob < ::ApplicationJob

    sns_event 'InsulinInjected'
    def create_injection
      injection_information = Health::InjectionParser.new(event).parse

      injection = Health::Injection.create!(
        units: injection_information[:units],
        injection_type: injection_information[:injection_type],
        notes: injection_information[:notes]
      )

      publish_injection_metric(injection)
    end

    private

    def publish_injection_metric(injection)
      AwsServices::CloudwatchWrapper.new.publish_injection(injection)
    end
  end
end
