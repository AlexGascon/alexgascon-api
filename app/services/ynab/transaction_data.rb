module Ynab
  class TransactionData
    CENTS_PER_EURO = 100

    attr_accessor :account_id, :amount, :approved, :category_id, :date, :memo

    def self.from_expense(expense)
      transaction = new

      transaction.amount = expense.amount * CENTS_PER_EURO
      transaction.date = expense.created_at.to_date.iso8601
      transaction.memo = expense.notes
      transaction.category_id = Ynab::Categories::CATEGORY_IDS[expense.category] || Ynab::Categories::UNCATEGORIZED_CATEGORY_ID
      transaction.account_id = Ynab::Accounts::ACCOUNT_IDS[Ynab::Accounts::DEFAULT]
      transaction.approved = true

      transaction
    end
  end
end
