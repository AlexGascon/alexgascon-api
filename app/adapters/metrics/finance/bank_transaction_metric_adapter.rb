# frozen_string_literal: true

module Metrics
  module Finance
    class BankTransactionMetricAdapter < BaseMetricAdapter
      METRIC_NAME = 'BankTransaction'

      def initialize(bank_transaction)
        self.metric_name = METRIC_NAME
        self.dimensions = [{ name: 'Bank', value: bank_transaction.bank }]
        self.timestamp = bank_transaction.datetime
        self.value = bank_transaction.amount
      end

      def namespace
        'Finance'
      end
    end
  end
end
