# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class GoogleOne < BaseRule
    def amount
      1.99
    end

    def description
      'Google Storage'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::GOOGLE_ONE_ID
    end
  end
end
