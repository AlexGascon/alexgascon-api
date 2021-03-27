# frozen_string_literal: true

RSpec.describe Finance::CreateExpenseJob do
  describe 'create_expense' do
    let(:fixture) { 'sns_events/finance/MoneySpent' }
    let(:event) { load_json_fixture fixture }
    let(:mock_cw) { instance_double(AwsServices::CloudwatchWrapper) }

    subject { described_class.perform_now(:create_expense, event) }

    before do
      allow(AwsServices::CloudwatchWrapper).to receive(:new).and_return(mock_cw)
      allow(mock_cw).to receive(:publish).and_return({})

      allow(Airtable::ExpensePublisher).to receive(:publish)
      allow(Ynab::ExpensePublisher).to receive(:publish)
    end

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

    it 'publishes the expense in CloudWatch' do
      expect(mock_cw).to receive(:publish)

      subject
    end

    it 'publishes the expense in YNAB' do
      expect(Ynab::ExpensePublisher).to receive(:publish)

      subject
    end

    it 'publishes the expense in Airtable' do
      expect(Airtable::ExpensePublisher).to receive(:publish)

      subject
    end

    context 'when the category is not in lowercase' do
      let(:fixture) { 'sns_events/finance/MoneySpent-uppercase' }

      it 'creates a new expense' do
        expect { subject }.to change { Finance::Expense.all.count }.by 1
      end

      it 'sets the category in lowercase' do
        expect(subject[:category]).to eq 'eating out'
      end
    end

    context 'when the category is invalid' do
      let(:fixture) { 'sns_events/finance/MoneySpent-invalid_category' }

      it 'raises a validation error' do
        expect { subject }.to raise_error Dynamoid::Errors::DocumentNotValid
      end
    end
  end
end
