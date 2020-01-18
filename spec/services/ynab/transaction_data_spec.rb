# frozen_string_literal: true

RSpec.describe Ynab::TransactionData do
  describe '.from_expense' do
    let(:expense) { Finance::Expense.new(amount: 42.24, notes: 'Expense for testing', category: 'eating out') }
    let(:default_account_id) { 'e1a73ac1-62aa-4c12-a012-040982104623' }

    subject(:transaction) { Ynab::TransactionData.from_expense(expense) }

    before { expense.save }

    it('sets the YNAB account_id') { expect(transaction.account_id).to eq default_account_id }
    it('sets the transaction amount in negative miliunits') { expect(transaction.amount).to eq -42240 }
    it('sets the transaction date') { expect(transaction.date).to eq Date.today.strftime('%Y-%m-%d') }
    it('sets the memo') { expect(transaction.memo).to eq 'Expense for testing' }
    it('sets the category id') { expect(transaction.category_id).to eq 'f8ba8264-2699-49b4-b233-1fca11788721' }

    context 'when the category is invalid' do
      let(:expense) { Finance::Expense.new(amount: 42.0, notes: 'Expense for testing', category: 'Something random') }
      let(:uncategorized_category_id) { 'e172c064-eb5c-4fb2-9bd7-ae5fe9af692f' }

      it 'sets the transaction as "Uncategorized"' do
        expect(transaction.category_id).to eq uncategorized_category_id
      end
    end
  end
end
