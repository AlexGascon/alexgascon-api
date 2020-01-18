# frozen_string_literal: true

RSpec.describe Airtable::Expense do
  let(:finance_expense) { Finance::Expense.new(amount: 42.24, notes: 'Expense for testing', category: 'eating out') }

  describe '.from_expense' do
    subject(:expense) { Airtable::Expense.from_expense(finance_expense) }

    before { finance_expense.save }

    it('sets the title') { expect(expense.title).to eq 'Expense for testing' }
    it('sets the amount') { expect(expense.amount).to eq 42.24 }
    it('sets the category') { expect(expense.category).to eq 'Bar / Restaurant' }
    it('sets the datetime') { expect(expense.datetime).to eq finance_expense.created_at.strftime('%Y-%m-%dT%H:%M:%S%Z') }
  end
end
