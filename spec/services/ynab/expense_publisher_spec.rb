# frozen_string_literal: true

RSpec.describe Ynab::ExpensePublisher do
  describe 'publish' do
    let(:mock_ynab) { instance_double(YNAB::API) }
    let(:finance_expense) do
      Finance::Expense.new(
        amount: 12,
        category: Finance::ExpenseCategories::SUPERMARKET,
        notes: 'test injection',
        created_at: Time.now
      )
    end


    before do
      allow(YNAB::API).to receive(:new).and_return(mock_ynab)
      allow(mock_ynab).to receive_message_chain(:transactions, :create_transaction)
    end

    it 'publishes the expense into YNAB' do
      expect(mock_ynab).to receive_message_chain(:transactions, :create_transaction)

      Ynab::ExpensePublisher.publish(finance_expense)
    end
  end
end
