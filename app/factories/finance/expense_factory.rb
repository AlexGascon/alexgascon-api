# frozen_string_literal: true

module Finance
  class ExpenseFactory
    def self.from_bank_transaction(bank_transaction)
      adapted_expense = Finance::BankTransactionExpenseAdapter.new(bank_transaction)
      expense_category = Finance::CategoryClassifier.category_id_for(bank_transaction)

      Finance::Expense.create!(
        amount: adapted_expense.amount,
        category: expense_category,
        notes: adapted_expense.notes
      )
    end
  end
end
