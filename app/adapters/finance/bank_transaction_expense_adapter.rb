# frozen_string_literal: true

module Finance
  class BankTransactionExpenseAdapter
    attr_reader :bank_transaction

    def initialize(bank_transaction)
      @bank_transaction = bank_transaction
    end

    def amount
      -bank_transaction.amount_in_cents / 100
    end

    def amount=(_)
      raise StandardError, "Cannot override amount for #{self.class} instances"
    end

    def category
      ExpenseCategories::UNDEFINED
    end

    def category=(_)
      raise StandardError, "Cannot override category for #{self.class} instances"
    end

    def notes
      bank_transaction.description
    end

    def notes=(_)
      raise StandardError, "Cannot override notes for #{self.class} instances"
    end
  end
end
