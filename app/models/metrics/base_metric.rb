# frozen_string_literal: true

module Metrics
  class BaseMetric < BaseMetricAdapter
    include Metricable

    def metric_adapter
      self
    end
  end
end
