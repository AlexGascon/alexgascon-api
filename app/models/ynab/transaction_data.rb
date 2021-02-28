# frozen_string_literal: true

module Ynab
  class TransactionData
    MILIUNITS_PER_EURO = 1000
    CONVERT_TO_EXPENSE = -1
    DEFAULT_ACCOUNT = Ynab::Accounts::ACCOUNT_IDS[Ynab::Accounts::DEFAULT]
    DEFAULT_CATEGORY = Ynab::Categories::UNCATEGORIZED_CATEGORY_ID

    attr_accessor :account_id, :amount, :approved, :category_id, :date, :memo

    def self.from_expense(expense)
      transaction = new

      transaction.amount = (expense.amount * MILIUNITS_PER_EURO * CONVERT_TO_EXPENSE).to_i
      transaction.approved = true
      transaction.date = expense.created_at.to_date.iso8601
      transaction.memo = expense.notes
      transaction.category_id = Ynab::Categories::CATEGORY_IDS[expense.category] || DEFAULT_CATEGORY
      transaction.account_id = DEFAULT_ACCOUNT

      transaction
    end

    def to_h
      {
        account_id: account_id,
        amount: amount,
        approved: approved,
        category_id: category_id,
        date: date,
        memo: memo
      }
    end
  end
end
