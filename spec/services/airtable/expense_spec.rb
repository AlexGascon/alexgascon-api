# frozen_string_literal: true

RSpec.describe Airtable::Expense do
  let(:finance_expense) { Finance::Expense.new(amount: 42.24, notes: 'Expense for testing', category: 'eating out') }

  before do
    allow_any_instance_of(described_class).to receive(:save)
  end

  describe '.from_expense' do
    subject(:expense) { Airtable::Expense.from_expense(finance_expense) }

    before { finance_expense.save }

    it 'sets the title' do
      expect(expense.title).to eq 'Expense for testing'
    end

    it 'sets the amount' do
      expect(expense.amount).to eq 42.24
    end

    it 'sets the category' do
      expect(expense.category).to eq 'Bar / Restaurant'
    end

    it 'sets the datetime' do
      expected_datetime = finance_expense.created_at.strftime('%Y-%m-%dT%H:%M:%S%Z')
      expect(expense.datetime).to eq expected_datetime
    end
  end
end
