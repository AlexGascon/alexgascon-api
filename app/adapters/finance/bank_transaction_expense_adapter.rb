# frozen_string_literal: true

module Finance
  class BankTransactionExpenseAdapter
    attr_reader :bank_transaction

    def initialize(bank_transaction)
      @bank_transaction = bank_transaction
    end

    def amount
      bank_transaction.amount_in_cents / 100
    end

    def category
      'Undefined'
    end

    def notes
      bank_transaction.description
    end
  end
end
