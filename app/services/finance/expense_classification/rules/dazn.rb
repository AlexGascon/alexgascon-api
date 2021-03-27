# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Dazn < BaseRule
    def amount
      9.99
    end

    def description
      'dazn'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::DAZN_ID
    end
  end
end
