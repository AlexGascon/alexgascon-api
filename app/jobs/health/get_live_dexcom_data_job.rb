# frozen_string_literal: true

module Health
  class GetLiveDexcomDataJob < ApplicationJob

    rate '5 minutes'
    def run
      bgs = ::Dexcom::BloodGlucose.get_last(minutes: 1440)

      bgs
        .map { |bg| Health::GlucoseValueFactory.from_dexcom_gem(bg, persist=true) }
        .each { |glucose_value| PublishCloudwatchDataCommand.new(glucose_value).execute }
    end
  end
end
