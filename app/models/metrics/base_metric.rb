# frozen_string_literal: true

class Metrics::BaseMetric < Aws::CloudWatch::Types::MetricDatum
  UNIT_COUNT = 'Count'

  def ==(other)
    other.class == self.class &&
      other.metric_name == self.metric_name &&
      other.value == self.value &&
      other.timestamp == self.timestamp &&
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
