# frozen_string_literal: true

module Health
  class GetLiveGlucoseDataJob < ApplicationJob

    rate '5 minutes'
    def run
      bg = ::Dexcom::BloodGlucose.last
      
      Health::GlucoseValueFactory.from_dexcom_gem(bg, persist=true)
    end
  end
end
