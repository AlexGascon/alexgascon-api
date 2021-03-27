# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Aws < BaseRule
    def description
      'aws emea'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::AWS_ID
    end
  end
end
