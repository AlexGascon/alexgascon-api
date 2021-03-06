# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class BaseRule
    attr_reader :amount, :description

    def matches?(expense)
      @expense = expense

      amount_matches? && description_matches?
    end

    private

    attr_reader :expense

    def amount_matches?
      return true if amount.nil?

      amount == expense.amount
    end

    def description_matches?
      return true if description.blank?

      expense.notes.downcase.include? description.downcase
    end
  end
end
