# frozen_string_literal: true

class PublishEmptyMetricsJob < ApplicationJob
  def publish
    cloudwatch = AwsServices::CloudwatchWrapper.new

    empty_basal = Health::Injection.new(injection_type: 'basal', units: 0)
    cloudwatch.publish_injection(empty_basal)

    empty_bolus = Health::Injection.new(injection_type: 'bolus', units: 0)
    cloudwatch.publish_injection(empty_bolus)

    Finance::ExpenseCategories::ALL.each do |category|
      empty_expense = Finance::Expense.new(amount: 0, category: category)
      cloudwatch.publish_expense(empty_expense)
    end
  end
end
