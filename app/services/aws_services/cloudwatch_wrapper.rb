# frozen_string_literal: true

module AwsServices
  class CloudwatchWrapper
    attr_reader :client

    def initialize
      @client = Aws::CloudWatch::Client.new
    end

    def publish_injection(injection)
      metric_data = Metrics::InjectionMetric.new(injection)
      client.put_metric_data(namespace: 'Health', metric_data: [metric_data])
    end

    def publish_expense(expense)
      metric_data = Metrics::ExpenseMetric.new(expense)
      client.put_metric_data(namespace: 'Finance', metric_data: [metric_data])
    end
  end
end
