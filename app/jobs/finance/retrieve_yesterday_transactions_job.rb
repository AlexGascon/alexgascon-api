# frozen_string_literal: true

module Finance
  class RetrieveYesterdayTransactionsJob < ::ApplicationJob

    cron '27 01 * * ? *'
    def run
      openbank = Finance::Openbank::Service.new
      transactions_data = openbank.get_transactions(Date.yesterday)

      return if transaction_data.empty?

      transactions_data.each do |transaction_data|
        Finance::Openbank::TransactionBuilder.new(transaction_data).build
      end
    end
  end
end
