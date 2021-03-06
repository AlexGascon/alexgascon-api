# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Deliveroo < BaseRule
    def description
      'deliveroo.ie'
    end

    def ynab_id
      Ynab::Categories::EATING_OUT_ID
    end
  end
end
