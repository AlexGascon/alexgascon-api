# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Netflix < BaseRule
    def amount
      11.99
    end

    def description
      'netflix'
    end

    def ynab_id
      Ynab::Categories::NETFLIX_ID
    end
  end
end
