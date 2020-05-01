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

      publish_expense_metric(expense)
      publish_expense_in_airtable(expense)
      publish_expense_in_ynab(expense)

      expense
    end

    private

    def publish_expense_metric(expense)
      AwsServices::CloudwatchWrapper.new.publish(expense)
    end

    def publish_expense_in_airtable(expense)
      Airtable::Expense.from_expense(expense)
    end

    def publish_expense_in_ynab(expense)
      ynab = YNAB::API.new(ENV['YNAB_TOKEN'])

      data = { transaction: Ynab::TransactionData.from_expense(expense).to_h }
      ynab.transactions.create_transaction(Ynab::Budgets::BUDGET_ID, data)
    end
  end
end
