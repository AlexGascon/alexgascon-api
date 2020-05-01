# frozen_string_literal: true

class PublishEmptyDatapointsJob < ApplicationJob

  rate '1 hour'
  def publish
    cloudwatch = AwsServices::CloudwatchWrapper.new

    Health::Injection::TYPES.each do |injection_type|
      empty_injection = Health::Injection.new(injection_type: injection_type, units: 0)
      cloudwatch.publish(empty_injection)
    end

    Finance::ExpenseCategories::ALL.each do |category|
      empty_expense = Finance::Expense.new(amount: 0, category: category)
      cloudwatch.publish(empty_expense)
    end
  end
end
