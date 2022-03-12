# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class LaMediaInglesa < BaseRule
    def amount
      4.99
    end

    def description
      'google *youtub'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::LA_MEDIA_INGLESA_ID
    end
  end
end
