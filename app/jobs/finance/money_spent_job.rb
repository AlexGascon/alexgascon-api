# frozen_string_literal: true

module Finance
  class MoneySpentJob < ::ApplicationJob

    sns_event 'MoneySpent'
    def run
      expense_information = Finance::ExpenseParser.new(event).parse

      Finance::Expense.create!(
        amount: expense_information[:amount],
        category: expense_information[:category],
        notes: expense_information[:notes]
      )
    end
  end
end
