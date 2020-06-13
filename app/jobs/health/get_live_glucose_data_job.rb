# frozen_string_literal: true

module Health
  class GetLiveGlucoseDataJob < ApplicationJob

    rate '5 minutes'
    def run
      bg = ::Dexcom::BloodGlucose.last
      
      glucose_value = Health::GlucoseValueFactory.from_dexcom_gem(bg, persist=true)
      PublishCloudwatchDataCommand.new(glucose_value).execute
    end
  end
end
