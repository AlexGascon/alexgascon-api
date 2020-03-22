# frozen_string_literal: true

module Finance
  class Expense
    include Dynamoid::Document

    ERROR_CATEGORY_INVALID = 'Invalid category'

    field :amount, :number
    field :category, :string
    field :notes, :string

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

    private

    def category_is_a_valid_expense_category
      errors.add(:category, ERROR_CATEGORY_INVALID) unless valid_category?
    end

    def valid_category?
      Finance::ExpenseCategories::ALL.include? category
    end
  end
end
