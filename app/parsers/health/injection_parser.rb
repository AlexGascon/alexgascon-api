# frozen_string_literal: true

module Health
  class InjectionParser < SnsParser
    def parse
      event.slice(:injection_type, :notes, :units)
    end
  end
end
