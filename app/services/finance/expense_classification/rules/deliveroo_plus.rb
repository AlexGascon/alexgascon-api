# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class DeliverooPlus < BaseRule
    def description
      'deliveroo plus'
    end

    def expense_category
      Finance::ExpenseCategories::SUBSCRIPTION
    end

    def ynab_id
      Ynab::Categories::DELIVEROO_PLUS_ID
    end
  end
end

