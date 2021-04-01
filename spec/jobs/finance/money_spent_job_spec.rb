# frozen_string_literal: true

RSpec.describe Finance::MoneySpentJob do
  describe 'run' do
    let(:fixture) { 'aws/sns/finance/MoneySpent' }
    let(:event) { load_json_fixture fixture }

    subject { described_class.perform_now(:run, event) }

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

    context 'when the category is not in lowercase' do
      let(:fixture) { 'aws/sns/finance/MoneySpent-uppercase' }

      it 'creates a new expense' do
        expect { subject }.to change { Finance::Expense.all.count }.by 1
      end

      it 'sets the category in lowercase' do
        expect(subject[:category]).to eq 'eating out'
      end
    end

    context 'when the category is invalid' do
      let(:fixture) { 'aws/sns/finance/MoneySpent-invalid_category' }

      it 'raises a validation error' do
        expect { subject }.to raise_error Dynamoid::Errors::DocumentNotValid
      end
    end
  end
end
