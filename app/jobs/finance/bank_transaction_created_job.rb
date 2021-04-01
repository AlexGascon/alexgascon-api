# frozen_string_literal: true

module Finance
  class BankTransactionCreatedJob < ::ApplicationJob

    dynamodb_event 'alexgascon-api_production_banktransactions'
    def run
      Jets.logger.info "DynamoDB event: #{event}"

      bank_transactions
        .map { |bank_transaction| convert_to_expense!(bank_transaction) }
        .each { |expense| publish_in_telegram(expense) }
    end

    private

    def bank_transactions
      @bank_transactions ||= parse_bank_transactions
    end

    def convert_to_expense!(bank_transaction)
      Finance::ExpenseFactory.from_bank_transaction(bank_transaction)
    end

    def publish_in_telegram(expense)
      SendTelegramMessageCommand.new(expense.to_s).execute
    end

    def parse_bank_transactions
      event['Records']
        .select { |record| new_transaction?(record) }
        .map { |record| record['dynamodb'] }
        .map { |dynamodb_record| extract_bank_transaction_id(dynamodb_record) }
        .map { |transaction_id| find_bank_transaction(transaction_id) }
    end

    def new_transaction?(record)
      record.has_key?('dynamodb') && record['eventName'] == 'INSERT'
    end

    def extract_bank_transaction_id(dynamodb_record)
      dynamodb_record.dig('Keys', 'id', 'S')
    end

    def find_bank_transaction(bank_transaction_id)
      Finance::BankTransaction.find(bank_transaction_id)
    end
  end
end
