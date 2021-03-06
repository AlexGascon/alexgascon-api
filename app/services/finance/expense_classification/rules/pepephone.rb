# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Pepephone < BaseRule
    def amount
      11.90
    end

    def description
      'pepemobile'
    end

    def ynab_id
      Ynab::Categories::PEPEPHONE_ID
    end
  end
end

