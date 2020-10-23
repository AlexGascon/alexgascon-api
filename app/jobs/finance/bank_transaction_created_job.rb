# frozen_string_literal: true

module Finance
  class BankTransactionCreatedJob < ::ApplicationJob

    dynamodb_event 'alexgascon-api_production_banktransactions'
    def run
      Jets.logger.info "DynamoDB event: #{event}"

      SendTelegramMessageCommand.new(bank_transaction.to_s).execute
    end

    private

    def bank_transaction
      @bank_transaction ||= get_bank_transaction
    end

    def get_bank_transaction
      bank_transaction_data = event['Records'].first['dynamodb']
      bank_transaction_id = bank_transaction_data.dig('keys', 'id', 'S')

      Finance::BankTransaction.find(bank_transaction_id)
    end
  end
end
