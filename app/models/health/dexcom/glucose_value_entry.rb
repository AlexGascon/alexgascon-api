# frozen_string_literal: true

module Health::Dexcom
  class GlucoseValueEntry
    attr_accessor :glucose_value, :timestamp, :transmitter_time, :transmitter_id, :source_device_id
  end
end
