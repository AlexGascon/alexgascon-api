# frozen_string_literal: true

module Finance
  class Expense
    include Dynamoid::Document
    include Metricable

    ERROR_CATEGORY_INVALID = 'Invalid category'

    field :amount, :number
    field :category, :string
    field :notes, :string

    alias amount_in_euros amount

    validates_presence_of :amount
    validates_presence_of :category
    validate :category_is_a_valid_expense_category

    def category=(value)
      self[:category] = value.downcase
    end

    def ==(other)
      other.class == self.class &&
        other.amount == amount &&
        other.category == category &&
        other.notes == notes
    end

    def to_s
      "Finance::Expense(amount: #{amount}, category: #{category}, notes: #{notes})"
    end

    private

    def category_is_a_valid_expense_category
      error_message = "#{ERROR_CATEGORY_INVALID}: #{category}"
      errors.add(:category, error_message) unless valid_category?
    end

    def valid_category?
      (Finance::ExpenseCategories::ALL.include? category) || category == Finance::ExpenseCategories::UNDEFINED
    end
  end
end
