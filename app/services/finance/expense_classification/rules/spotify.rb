# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Spotify < BaseRule
    def amount
      9.99
    end

    def description
      'spotify'
    end

    def airtable_category
      Airtable::Categories::SUBSCRIPTIONS
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::SPOTIFY_ID
    end
  end
end
