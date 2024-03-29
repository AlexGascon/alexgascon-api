# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Deliveroo < BaseRule
    def description_matches?
      expense.notes.downcase.include?('deliveroo') && !expense.notes.downcase.include?('plus')
    end

    def airtable_category
      Airtable::Categories::BAR_RESTAURANT
    end

    def expense_category
      Finance::ExpenseCategories::EATING_OUT
    end

    def ynab_id
      Ynab::Categories::EATING_OUT_ID
    end
  end
end
