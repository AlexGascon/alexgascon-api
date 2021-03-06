# frozen_string_literal: true

RSpec.describe Finance::ExpenseParser do
  let(:parser) { described_class.new(sns_event) }

  describe '#parse' do
    let(:sns_event) { load_json_fixture('aws/sns/finance/MoneySpent') }

    subject { parser.parse }

    it 'returns a hash with the expense information' do
      expected_expense = { amount: 42.24, category: 'eating out', notes: 'Expense testing notes' }

      expect(subject).to eq expected_expense
    end
  end
end
