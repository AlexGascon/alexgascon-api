# frozen_string_literal: true

module Metrics
  module Health
    class GlucoseValueMetricAdapter < BaseMetricAdapter
      METRIC_NAME = 'Glucose'

      def initialize(glucose_value_entry)
        self.metric_name = METRIC_NAME
        self.timestamp = glucose_value_entry.timestamp
        self.value = glucose_value_entry.value.to_f
      end

      def namespace
        'Health'
      end
    end
  end
end
