# frozen_string_literal: true

module Health
  class InjectionParser < SnsParser
    def parse
      {
        injection_type: event[:type],
        notes: event[:notes],
        units: event[:units]
      }
    end
  end
end
