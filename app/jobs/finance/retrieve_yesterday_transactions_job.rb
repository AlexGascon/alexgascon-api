# frozen_string_literal: true

module Finance
  class RetrieveYesterdayTransactionsJob < ::ApplicationJob

    cron '27 03 * * ? *'
    def run
      transactions = [openbank_transactions + bankia_transactions]

      transactions
        .each { |bank_transaction| publish_in_cloudwatch(bank_transaction) }
    end

    private

    def openbank_transactions
      openbank = Finance::Openbank::Service.new
      transactions_data = openbank.get_transactions(yesterday)

      return if transactions_data.empty?

      transactions_data
        .map { |transaction_data| Finance::Openbank::TransactionBuilder.new(transaction_data).build }
    end

    def bankia_transactions
      bankia = Finance::Bankia::Service.new
      transactions_data = bankia.get_transactions(yesterday)

      return if transactions_data.empty?

      transactions_data
        .map { |transaction_data| Finance::Bankia::TransactionBuilder.new(transaction_data).build }
    end

    def yesterday
      DateTime.now.utc.yesterday.to_date
    end

    def publish_in_cloudwatch(bank_transaction)
      PublishCloudwatchDataCommand.new(bank_transaction).execute
    end
  end
end
