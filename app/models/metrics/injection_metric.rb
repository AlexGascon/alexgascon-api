# frozen_string_literal: true

module Metrics
  class InjectionMetric < BaseMetric
    METRIC_NAME = 'Insulin'

    def initialize(injection)
      self.metric_name = METRIC_NAME
      self.dimensions = [{ name: 'Type', value: injection.injection_type }]
      self.timestamp = injection.created_at
      self.value = injection.units.to_f
      self.unit = UNIT_COUNT
    end
  end
end
