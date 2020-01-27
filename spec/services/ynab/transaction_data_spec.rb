# frozen_string_literal: true

RSpec.describe Ynab::TransactionData do
  let(:expense) { Finance::Expense.new(amount: 42.24, notes: 'Expense for testing', category: 'eating out') }
  let(:default_account_id) { 'e1a73ac1-62aa-4c12-a012-040982104623' }
  let(:eating_out_category_id) { 'f8ba8264-2699-49b4-b233-1fca11788721' }

  describe '.from_expense' do
    subject(:transaction) { Ynab::TransactionData.from_expense(expense) }

    before { expense.save }

    it('sets the YNAB account_id') { expect(transaction.account_id).to eq default_account_id }
    it('sets the transaction amount in negative miliunits') { expect(transaction.amount).to eq -42_240 }
    it('sets the transaction date') { expect(transaction.date).to eq Date.today.strftime('%Y-%m-%d') }
    it('sets the memo') { expect(transaction.memo).to eq 'Expense for testing' }
    it('sets the category id') { expect(transaction.category_id).to eq eating_out_category_id }
    it('marks the transaction as approved') { expect(transaction.approved).to be true }

    context 'when the category is invalid' do
      let(:expense) { Finance::Expense.new(amount: 42.0, notes: 'Expense for testing', category: 'Something random') }
      let(:uncategorized_category_id) { 'e172c064-eb5c-4fb2-9bd7-ae5fe9af692f' }

      it 'sets the transaction as "Uncategorized"' do
        expect(transaction.category_id).to eq uncategorized_category_id
      end
    end
  end

  describe '#to_h' do
    let(:amount) { -42_240 }
    let(:notes) { 'Transaction for testing' }
    let(:date) { Date.today.strftime('%Y-%m-%d') }

    let(:transaction) { Ynab::TransactionData.new }

    before do
      transaction.amount = amount
      transaction.approved = true
      transaction.memo = notes
      transaction.category_id = eating_out_category_id
      transaction.account_id = default_account_id
      transaction.date = date
    end

    subject { transaction.to_h }

    it { expect(subject[:amount]).to eq transaction.amount }
    it { expect(subject[:category_id]).to eq transaction.category_id }
    it { expect(subject[:account_id]).to eq transaction.account_id }
    it { expect(subject[:memo]).to eq transaction.memo }
    it { expect(subject[:date]).to eq transaction.date }
    it { expect(subject[:approved]).to eq true }

    it 'has the correct keys' do
      expected_keys = %i[amount category_id account_id memo date approved]
      expect(subject.keys).to contain_exactly(*expected_keys)
    end
  end
end
