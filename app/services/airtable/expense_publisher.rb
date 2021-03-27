# frozen_string_literal: true

module Airtable
  class ExpensePublisher
    def self.publish(finance_expense)
      Airtable::Expense.from_expense(finance_expense)
    end
  end
end
