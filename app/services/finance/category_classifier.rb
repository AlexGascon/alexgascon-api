# frozen_string_literal: true

module Finance
  class CategoryClassifier
    def self.category_id_for(bank_transaction)
      bank_expense = Finance::BankTransactionExpenseAdapter.new(bank_transaction)

      matching_rule =
        Finance::ExpenseClassification::Rules::ALL
        .map(&:new)
        .find { |rule| rule.matches?(bank_expense) }

      return matching_rule.expense_category if matching_rule.present?

      Finance::ExpenseCategories::UNDEFINED
    end
  end
end
