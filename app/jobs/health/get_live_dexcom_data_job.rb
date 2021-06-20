# frozen_string_literal: true

module Health
  class GetLiveDexcomDataJob < ApplicationJob
    THREE_HOURS_IN_MINUTES = 180

    rate '5 minutes'
    def run
      bgs = ::Dexcom::BloodGlucose.get_last(minutes: THREE_HOURS_IN_MINUTES)

      Health::GlucoseValueFactory
        .from_dexcom_gem_entries(bgs)
        .reject { |glucose_value| already_published?(glucose_value) }
        .tap { |glucose_values| Jets.logger.info "Number of glucose values to publish: #{glucose_values.size}" }
        .each { |glucose_value| publish(glucose_value) }
    end

    private

    def already_published?(glucose_value)
      Redis.current.get(glucose_value.timestamp.to_s).present?
    rescue Redis::BaseError
      Jets.logger.warn 'Redis is unavailable - Skipping cache read'
      publish_redis_metric

      false
    end

    def publish(glucose_value)
      PublishCloudwatchDataCommand.new(glucose_value).execute

      Redis.current.set(glucose_value.timestamp.to_s, true)
    rescue Redis::BaseError
      Jets.logger.warn 'Redis is unavailable - Skipping cache write'
      publish_redis_metric
    end

    def publish_redis_metric
      metric = Metrics::BaseMetric.new
      metric.namespace = Metrics::Namespaces::INFRASTRUCTURE
      metric.unit = Metrics::Units::COUNT
      metric.timestamp = DateTime.now
      metric.dimensions = [{ name: 'Component', value: 'Redis' }]
      metric.metric_name = 'Error'
      metric.value = 1

      PublishCloudwatchDataCommand.new(metric).execute
    end
  end
end
