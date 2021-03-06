# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Aws < BaseRule
    def description
      'aws emea'
    end

    def ynab_id
      Ynab::Categories::AWS_ID
    end
  end
end
