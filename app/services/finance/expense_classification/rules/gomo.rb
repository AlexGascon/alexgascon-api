# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Gomo < BaseRule
    def amount
      14.99
    end

    def description
      'gomo'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::GOMO_ID
    end
  end
end
