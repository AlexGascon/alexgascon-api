# frozen_string_literal: true

RSpec.describe Finance::CreateExpenseJob do
  describe 'create_expense' do
    let(:event) { JSON.parse(File.read('spec/fixtures/sns_events/finance/MoneySpent.json')) }
    let(:mock_cw) { instance_double(AwsServices::CloudwatchWrapper) }
    let(:mock_ynab) { instance_double(YNAB::API) }

    subject { described_class.perform_now(:create_expense, event) }

    before do
      allow(AwsServices::CloudwatchWrapper).to receive(:new).and_return(mock_cw)
      allow(mock_cw).to receive(:publish_expense).and_return({})

      allow(YNAB::API).to receive(:new).and_return(mock_ynab)
      allow(mock_ynab).to receive_message_chain(:transactions, :create_transaction)
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
      expect(mock_cw).to receive(:publish_expense)

      subject
    end

    it 'publishes the expense in YNAB' do
      expect(mock_ynab).to receive_message_chain(:transactions, :create_transaction)

      subject
    end
  end
end
