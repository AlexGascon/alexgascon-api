# frozen_string_literal: true

module Finance
  class Expense
    include Dynamoid::Document

    field :amount, :number
    field :category, :string
    field :notes, :string

    validates_presence_of :amount
    validates_presence_of :category

    def ==(other)
      other.class == self.class &&
        other.amount == self.amount &&
        other.category == self.category &&
        other.notes == self.notes
    end
  end
end
