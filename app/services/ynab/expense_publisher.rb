# frozen_string_literal: true

module Ynab
  class ExpensePublisher
    def self.publish(expense)
      ynab = YNAB::API.new(ENV['YNAB_TOKEN'])

      data = { transaction: Ynab::TransactionData.from_expense(expense).to_h }
      ynab.transactions.create_transaction(Ynab::Budgets::BUDGET_ID, data)
    end
  end
end
