# frozen_string_literal: true

module Finance
  class BankTransactionCreatedJob < ::ApplicationJob

    dynamodb_event 'alexgascon-api_production_banktransactions'
    def run
      Jets.logger.info "DynamoDB event: #{event}"

      bank_transactions.map do |bank_transaction|
        SendTelegramMessageCommand.new(bank_transaction.to_s).execute
      end
    end

    private

    def bank_transactions
      @bank_transactions ||= parse_bank_transactions
    end

    def parse_bank_transactions
      event['Records']
        .map { |record| record['dynamodb'] }
        .map { |dynamodb_record| extract_bank_transaction_id(record) }
        .map { |transaction_id| find_bank_transaction(transaction_id) }
      end
    end

    def extract_bank_transaction_id(dynamodb_record)
      dynamodb_record.dig('Keys', 'id', 'S')
    end

    def find_bank_transaction(bank_transaction_id)
      Finance::BankTransaction.find(bank_transaction_id)
    end
  end
end
