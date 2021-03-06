# frozen_string_literal: true

module Ynab
  class CategoryClassifier
    DEFAULT_CATEGORY = Ynab::Categories::UNCATEGORIZED_CATEGORY_ID

    DIRECT_MATCHES = {
      Finance::ExpenseCategories::COCA_COLA => Ynab::Categories::COCA_COLA_ID,
      Finance::ExpenseCategories::EATING_OUT => Ynab::Categories::EATING_OUT_ID,
      Finance::ExpenseCategories::FUN => Ynab::Categories::FUN_ID,
      Finance::ExpenseCategories::SUPERMARKET => Ynab::Categories::SUPERMARKET_ID
    }.freeze

    def self.category_id_for(expense)
      matching_rule =
        Finance::ExpenseClassification::Rules::ALL
        .map(&:new)
        .find { |rule| rule.matches?(expense) }

      return matching_rule.ynab_id if matching_rule.present?

      return DIRECT_MATCHES[expense.category] if DIRECT_MATCHES.has_key?(expense.category)

      DEFAULT_CATEGORY
    end
  end
end
