# frozen_string_literal: true

module Metricable
  include ActiveSupport::Concern

  delegate :namespace, :data, prefix: :metric, to: :metric_adapter

  def metric_adapter
    @metric_adapter ||= metric_adapter_class.new(self)
  end

  def metric_adapter_class
    "Metrics::#{self.class.name}MetricAdapter".constantize
  end
end
