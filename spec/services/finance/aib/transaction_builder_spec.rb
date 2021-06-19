# frozen_string_literal: true

RSpec.describe Finance::Aib::TransactionBuilder do
  let(:transaction_information) { load_json_fixture 'finance/aib/transaction' }

  describe '#build' do
    subject(:bank_transaction) { described_class.new(transaction_information).build }

    it 'sets the amount_in_cents' do
      expect(bank_transaction.amount_in_cents).to eq -2000
    end

    it 'sets the bank' do
      expect(bank_transaction.bank).to eq 'AIB'
    end

    it 'sets the datetime' do
      expect(bank_transaction.datetime).to eq DateTime.parse('2021-05-24')
    end

    it 'sets the description' do
      expect(bank_transaction.description).to eq 'ATM FAKE STREET 22MAY21 TIME 12:18'
    end

    it 'sets the internal_id' do
      expect(bank_transaction.internal_id).to eq 'aJgKYrKa7Yt7oe3pb68qiX509M3gKgCjb9J4y'
    end

    it 'sets year_month' do
      expect(bank_transaction.year_month).to eq '2021-05'
    end

    it 'sets day' do
      expect(bank_transaction.day).to eq '24'
    end
  end
end
