# frozen_string_literal: true

module Finance::ExpenseClassification::Rules
  class BaseRule
    attr_reader :amount, :description

    def matches?(expense)
      if rule_implementation_error?
        raise NotImplementedError, "No matching criteria implemented in #{self.class}, this rule will match any expense"
      end

      @expense = expense

      amount_matches? && description_matches?
    end

    def airtable_category
      raise NotImplementedError, "airtable_category not implemented for #{self.class}"
    end

    def expense_category
      raise NotImplementedError, "expense_category not implemented for #{self.class}"
    end

    def ynab_id
      raise NotImplementedError, "ynab_id not implemented for #{self.class}"
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

    def rule_implementation_error?
      amount.nil? && description.blank? &&
        self.method(:amount_matches?).owner != self.class &&
        self.method(:description_matches?).owner != self.class
    end
  end
end
