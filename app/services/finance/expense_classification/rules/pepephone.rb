# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Pepephone < BaseRule
    def amount
      11.90
    end

    def description
      'pepemobile'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::PEPEPHONE_ID
    end
  end
end

