# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Internet < BaseRule
    def amount
      59.00
    end

    def description
      'virgin media'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::INTERNET_ID
    end
  end
end

