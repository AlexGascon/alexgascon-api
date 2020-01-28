# frozen_string_literal: true

module Airtable
  class Expense < Airrecord::Table
    self.table_name = 'Expense Tracking'

    ATTRIBUTE_TO_COLUMN = {
      'amount' => 'Total',
      'category' => 'Category',
      'datetime' => 'Date & Time',
      'title' => 'Short Description'
    }.freeze

    def self.from_expense(finance_expense)
      expense = new({})

      expense.amount = finance_expense.amount
      expense.category = Airtable::Categories::MAPPING[finance_expense.category]
      expense.datetime = finance_expense.created_at.iso8601
      expense.title = finance_expense.notes

      expense
    end

    ATTRIBUTE_TO_COLUMN.keys.each do |attribute|
      column = ATTRIBUTE_TO_COLUMN[attribute]

      define_method("#{attribute}") do
        self[column]
      end

      define_method("#{attribute}=") do |value|
        self[column] = value
      end
    end
  end
end
