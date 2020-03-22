# frozen_string_literal: true

module Finance
  class Expense
    include Dynamoid::Document

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
      errors.add(:category, 'Invalid category') unless Finance::ExpenseCategories::ALL.include? category
    end
  end
end
