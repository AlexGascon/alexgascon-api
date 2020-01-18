# frozen_string_literal: true

module Airtable
  class Expense < Airrecord::Table
    self.table_name = 'Expense Tracking'

    # Column names
    AMOUNT = 'Total'
    CATEGORY = 'Category'
    DATETIME = 'Date & Time'
    TITLE = 'Short Description'

    def self.from_expense(finance_expense)
      expense = new({})

      expense.amount = finance_expense.amount
      expense.category = Airtable::Categories::MAPPING[finance_expense.category]
      expense.datetime = finance_expense.created_at.iso8601
      expense.title = finance_expense.notes

      expense
    end

    def amount
      self[AMOUNT]
    end

    def amount=(value)
      self[AMOUNT] = value
    end

    def category
      self[CATEGORY]
    end

    def category=(value)
      self[CATEGORY] = value
    end

    def datetime
      self[DATETIME]
    end

    def datetime=(value)
      self[DATETIME] = value
    end

    def title
      self[TITLE]
    end

    def title=(value)
      self[TITLE] = value
    end
  end
end
