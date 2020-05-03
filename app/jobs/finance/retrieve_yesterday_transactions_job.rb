# frozen_string_literal: true

module Finance
  class RetrieveYesterdayTransactionsJob < ::ApplicationJob

    cron '27 03 * * ? *'
    def run
      openbank = Finance::Openbank::Service.new
      transactions_data = openbank.get_transactions(yesterday)

      return if transactions_data.empty?

      transactions_data
        .map { |transaction_data| create_bank_transaction(transaction_data) }
        .each { |bank_transaction| publish_in_cloudwatch(bank_transaction) }
    end

    private

    def yesterday
      DateTime.now.utc.yesterday.to_date
    end

    def create_bank_transaction(transaction_data)
      Finance::Openbank::TransactionBuilder.new(transaction_data).build
    end

    def publish_in_cloudwatch(bank_transaction)
      PublishCloudwatchDataCommand.new(bank_transaction).execute
    end
  end
end
