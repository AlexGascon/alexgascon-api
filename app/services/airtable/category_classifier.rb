# frozen_string_literal: true

module Airtable
  class CategoryClassifier
    def self.category_id_for(expense)
      matching_rule =
        Finance::ExpenseClassification::Rules::ALL
        .map(&:new)
        .find { |rule| rule.matches?(expense) }

      return matching_rule.airtable_category if matching_rule.present?
    end
  end
end
