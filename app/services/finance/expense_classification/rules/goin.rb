# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Goin < BaseRule
    def description
      'goin'
    end

    def airtable_category
      Airtable::Categories::INVESTMENTS
    end

    def expense_category
      Finance::ExpenseCategories::INVESTMENT
    end

    def ynab_id
      Ynab::Categories::INVESTMENTS_ID
    end
  end
end
