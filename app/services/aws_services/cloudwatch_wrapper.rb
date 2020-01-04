# frozen_string_literal: true

module AwsServices
  class CloudwatchWrapper
    attr_reader :client

    def initialize
      @client = Aws::CloudWatch::Client.new
    end

    def publish_injection(injection)
      client.put_metric_data(
        namespace: 'Health',
        metric_data: [{
          metric_name: 'Insulin',
          dimensions: [{
            name: 'Type',
            value: injection.injection_type
          }],
          timestamp: injection.created_at,
          value: injection.units.to_f,
          unit: 'Count'
        }]
      )
    end

    def publish_expense(expense)
      client.put_metric_data(
        namespace: 'Finance',
        metric_data: [{
          metric_name: 'Money spent',
          timestamp: expense.created_at,
          dimensions: [{
            name: 'Category',
            value: expense.category
          }],
          value: expense.amount
        }]
      )
    end
  end
end
