# frozen_string_literal: true

module AwsServices
  class CloudwatchWrapper
    attr_reader :client

    METRIC_WIDGET_SOURCES_PATH = 'app/resources/json/aws/metric_widget_sources'
    WIDGET_LAST_DAY = 'insulin-last-day'

    def initialize
      @client = Aws::CloudWatch::Client.new
    end

    def publish(metricable)
      Jets.logger.info "METRICABLE: Namespace=#{metricable.metric_namespace}, Data=(#{metricable.metric_data})"

      client.put_metric_data(namespace: metricable.metric_namespace, metric_data: [metricable.metric_data])
    end

    def retrieve_insulin_last_day_image
      metric_widget = get_metric_widget_image WIDGET_LAST_DAY
      s3.store_image(metric_widget)
    end

    private

    def s3
      @s3 ||= AwsServices::S3Wrapper.new
    end

    def telegram
      @telegram ||= TelegramBot.new
    end

    def get_metric_widget_image(widget_source_name)
      metric_widget_source = File.read "#{METRIC_WIDGET_SOURCES_PATH}/#{widget_source_name}.json"
      response = client.get_metric_widget_image(metric_widget: metric_widget_source)

      response['metric_widget_image']
    end
  end
end
