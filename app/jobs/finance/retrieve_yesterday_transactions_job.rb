# frozen_string_literal: true

module Finance
  class RetrieveYesterdayTransactionsJob < ::ApplicationJob

    BANKS = %w[Aib Openbank].freeze

    cron '27 08 * * ? *'
    def run
      BANKS
        .map { |bank_name| retrieve_transactions(bank_name) }
        .flatten
    end

    private

    def retrieve_transactions(bank_name)
      bank = "Finance::#{bank_name}::Service".constantize
      transaction_builder = "Finance::#{bank_name}::TransactionBuilder".constantize

      transactions_data = bank.new.get_transactions(yesterday)

      return [] if transactions_data.empty?

      transactions_data
        .map { |transaction_data| transaction_builder.new(transaction_data).build }
    end

    def yesterday
      Time.now.utc.yesterday.beginning_of_day
    end

    def publish_in_cloudwatch(bank_transaction)
      PublishCloudwatchDataCommand.new(bank_transaction).execute
    end
  end
end
