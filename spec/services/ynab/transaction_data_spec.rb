# frozen_string_literal: true

RSpec.describe Ynab::TransactionData do
  let(:category) { 'eating out' }
  let(:expense) { Finance::Expense.new(amount: 42.24, notes: 'Expense for testing', category: category, created_at: Time.now) }
  let(:default_account_id) { 'e1a73ac1-62aa-4c12-a012-040982104623' }
  let(:eating_out_category_id) { 'f8ba8264-2699-49b4-b233-1fca11788721' }

  describe '.from_expense' do
    subject(:transaction) { Ynab::TransactionData.from_expense(expense) }

    before { expense.save }

    it 'sets the YNAB account_id' do
      expect(transaction.account_id).to eq default_account_id
    end

    it 'sets the transaction amount in negative miliunits' do
      expect(transaction.amount).to eq(-42_240)
    end

    it 'sets the transaction date' do
      expected_date = Date.today.strftime('%Y-%m-%d')
      expect(transaction.date).to eq expected_date
    end

    it 'sets the memo' do
      expect(transaction.memo).to eq 'Expense for testing'
    end

    it 'sets the category id' do
      expect(transaction.category_id).to eq eating_out_category_id
    end

    it 'marks the transaction as approved' do
      expect(transaction.approved).to be true
    end

    context 'when the category is not mapped' do
      let(:category) { 'Something random' }

      it 'sets the transaction as "Uncategorized"' do
        uncategorized_category_id = 'e172c064-eb5c-4fb2-9bd7-ae5fe9af692f'
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

    expected_attributes = %i[amount category_id account_id memo date approved]

    expected_attributes.each do |attribute|
      it "maps #{attribute} correctly" do
        attribute_value = transaction.send(attribute)
        expect(subject[attribute]).to eq attribute_value
      end
    end

    it 'has the correct keys' do
      expect(subject.keys).to contain_exactly(*expected_attributes)
    end
  end
end
