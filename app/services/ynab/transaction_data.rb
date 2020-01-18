module Ynab
  class TransactionData
    MILIUNITS_PER_EURO = 1000
    CONVERT_TO_EXPENSE = -1

    attr_accessor :account_id, :amount, :category_id, :date, :memo

    def self.from_expense(expense)
      transaction = new

      transaction.amount = (expense.amount * MILIUNITS_PER_EURO * CONVERT_TO_EXPENSE).to_i
      transaction.date = expense.created_at.to_date.iso8601
      transaction.memo = expense.notes
      transaction.category_id = Ynab::Categories::CATEGORY_IDS[expense.category] || Ynab::Categories::UNCATEGORIZED_CATEGORY_ID
      transaction.account_id = Ynab::Accounts::ACCOUNT_IDS[Ynab::Accounts::DEFAULT]

      transaction
    end
  end
end
