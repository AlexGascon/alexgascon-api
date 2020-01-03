# frozen_string_literal: true

RSpec.describe Finance::CreateExpenseJob do
  describe 'create_expense' do
    let(:event) { JSON.parse(File.read('spec/fixtures/sns_events/finance/MoneySpent.json')) }

    subject { described_class.perform_now(:create_expense, event) }

    it 'creates a new expense' do
      expect { subject }.to change { Finance::Expense.all.count }.by 1
    end

    it 'returns the expense' do
      expect(subject).to be_a_kind_of Finance::Expense
    end

    it 'sets the expense attributes correctly' do
      expense = subject

      expect(expense.amount).to eq 42.24
      expect(expense.category).to eq 'eating out'
      expect(expense.notes).to eq 'Expense testing notes'
    end
  end
end
