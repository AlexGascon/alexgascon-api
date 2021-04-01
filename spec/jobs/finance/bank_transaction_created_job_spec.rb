# frozen_string_literal: true

RSpec.describe Finance::BankTransactionCreatedJob do
  describe '#run' do
    let(:fixture) { 'aws/dynamodb/bank_transaction_created' }
    let(:event) { load_json_fixture fixture }

    before do
      create(:dynamodb_event_bank_transaction)
      stub_command(SendTelegramMessageCommand)
    end

    subject { described_class.perform_now(:run, event) }

    it 'creates a new expense' do
      expect { subject }.to change { Finance::Expense.all.count }.by 1
    end

    it 'returns a list of the created expenses' do
      result = subject

      expect(result).to be_a_kind_of Array
      expect(result.first).to be_a_kind_of Finance::Expense
    end

    it 'sets the expense attributes correctly' do
      result = subject
      expense = result.first

      expect(expense.amount).to eq 9.99
      expect(expense.category).to eq Finance::ExpenseCategories::SUBSCRIPTION
      expect(expense.notes).to eq 'COMPRA EN PAYPAL *SPOTIFY, CON LA TARJETA : XXXXXXXXXXXX4205 EL 2021-03-22'
    end

    it 'publishes the expense details to Telegram' do
      expect(SendTelegramMessageCommand).to receive(:new).once
      subject
    end
  end
end
