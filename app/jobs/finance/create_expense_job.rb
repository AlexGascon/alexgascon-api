# frozen_string_literal: true

module Finance
  class CreateExpenseJob < ::ApplicationJob
    sns_event 'MoneySpent'

    def create_expense
      expense_information = Finance::ExpenseParser.new(event).parse

      expense = Finance::Expense.create!(
        amount: expense_information[:amount],
        category: expense_information[:category],
        notes: expense_information[:notes]
      )
    end
  end
end
