# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class DisneyPlus < BaseRule
    def amount
      8.99
    end

    def description
      'disney plus'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::DISNEY_PLUS_ID
    end
  end
end
