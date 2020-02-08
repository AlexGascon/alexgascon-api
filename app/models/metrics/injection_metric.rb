# frozen_string_literal: true

module Metrics
  class InjectionMetric < BaseMetric
    METRIC_NAME = 'Insulin'

    DIMENSION_BASAL = 'Basal'
    DIMENSION_BOLUS = 'Bolus'

    def initialize(injection)
      self.metric_name = METRIC_NAME
      self.dimensions = [{ name: 'Type', value: map_injection_type(injection) }]
      self.timestamp = injection.created_at
      self.value = injection.units.to_f
      self.unit = UNIT_COUNT
    end

    private

    def map_injection_type(injection)
      {
        'basal' => DIMENSION_BASAL,
        'bolus' => DIMENSION_BOLUS
      }[injection.injection_type]
    end
  end
end
