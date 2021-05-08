# frozen_string_literal: true

module Health
  class GetLiveDexcomDataJob < ApplicationJob

    rate '5 minutes'
    def run
      bgs = ::Dexcom::BloodGlucose.get_last(minutes: 180)

      Health::GlucoseValueFactory
        .from_dexcom_gem_entries(bgs)
        .tap { |glucose_values| Jets.logger.info "Number of glucose values to publish: #{glucose_values.size}" }
        .each { |glucose_value| PublishCloudwatchDataCommand.new(glucose_value).execute }
    end
  end
end
