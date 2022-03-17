# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class Supermercado < BaseRule
    def description_matches?
     description = expense.notes.downcase

     description.include?('tesco') ||
     description.include?('lidl') ||
     description.include?('supervalu') ||
     description.include?('mercadona')
    end

    def airtable_category
      Airtable::Categories::SUPERMARKET
    end

    def expense_category
      Finance::ExpenseCategories::SUPERMARKET
    end

    def ynab_id
      Ynab::Categories::SUPERMARKET_ID
    end
  end
end

