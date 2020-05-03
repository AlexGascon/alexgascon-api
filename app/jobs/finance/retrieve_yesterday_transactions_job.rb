# frozen_string_literal: true

module Finance
  class RetrieveYesterdayTransactionsJob < ::ApplicationJob

    cron '27 03 * * ? *'
    def run
      openbank = Finance::Openbank::Service.new
      transactions_data = openbank.get_transactions(yesterday)

      return if transactions_data.empty?

      transactions_data.each do |transaction_data|
        Finance::Openbank::TransactionBuilder.new(transaction_data).build
      end
    end

    private

    def yesterday
      DateTime.now.utc.yesterday.to_date
    end
  end
end
