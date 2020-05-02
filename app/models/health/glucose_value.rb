# frozen_string_literal: true

module Health
  class GlucoseValue
    include Dynamoid::Document
    include Metricable

    field :value, :number
    field :timestamp, :datetime, store_as_string: true
  end
end
