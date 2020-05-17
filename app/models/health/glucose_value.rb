# frozen_string_literal: true

module Health
  class GlucoseValue
    include Dynamoid::Document
    include Metricable

    table write_capacity: 4

    field :value, :number
    field :timestamp, :datetime, store_as_string: true
  end
end
