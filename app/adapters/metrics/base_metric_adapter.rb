# frozen_string_literal: true

module Metrics
  class BaseMetricAdapter < Aws::CloudWatch::Types::MetricDatum
    include Namespaces
    include Units

    attr_accessor :namespace

    def data
      self
    end

    def ==(other)
      other.namespace == namespace &&
        other.metric_name == metric_name &&
        other.value == value &&
        other.timestamp == timestamp &&
        compare_dimensions(other)
    end

    def contains_dimension?(other_dimension)
      dimensions.any? { |dimension| dimension == other_dimension }
    end

    private

    def compare_dimensions(other)
      return false unless dimensions.size == other.dimensions.size

      other.dimensions.all? { |dimension| contains_dimension?(dimension) }
    end
  end
end
