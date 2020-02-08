# frozen_string_literal: true

module Metrics
  class ExpenseMetric < BaseMetric
    METRIC_NAME = 'Money spent'

    def initialize(expense)
      self.metric_name = METRIC_NAME
      self.dimensions = [{ name: 'Category', value: expense.category }]
      self.timestamp = expense.created_at
      self.value = expense.amount.to_f
    end
  end
end
