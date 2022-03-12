# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Pepephone < BaseRule
    def description
      'pepe mobile'
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
