# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class DeliverooPlus < BaseRule
    def description
      'deliveroo plus'
    end

    def ynab_id
      Ynab::Categories::DELIVEROO_PLUS_ID
    end
  end
end

