# frozen_string_literal: true

module Metrics
  module Finance
    class ExpenseMetricAdapter < BaseMetricAdapter
      METRIC_NAME = 'Money spent'

      DIMENSION_COCA_COLA = 'Coca cola'
      DIMENSION_EATING_OUT = 'Eating out'
      DIMENSION_FUN = 'Fun'
      DIMENSION_SUPERMARKET = 'Supermarket'

      def initialize(expense)
        self.metric_name = METRIC_NAME
        self.dimensions = [{ name: 'Category', value: map_category(expense) }]
        self.timestamp = expense.created_at
        self.value = expense.amount.to_f
      end

      def namespace
        'Finance'
      end

      private

      def map_category(expense)
        {
          ::Finance::ExpenseCategories::COCA_COLA => DIMENSION_COCA_COLA,
          ::Finance::ExpenseCategories::EATING_OUT => DIMENSION_EATING_OUT,
          ::Finance::ExpenseCategories::FUN => DIMENSION_FUN,
          ::Finance::ExpenseCategories::SUPERMARKET => DIMENSION_SUPERMARKET
        }[expense.category]
      end
    end
  end
end
