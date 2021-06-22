# frozen_string_literal: true

RSpec.describe Finance::Aib::TransactionBuilder do
  let(:transaction_information) { build(:plaid_transaction) }

  describe '#build' do
    subject(:bank_transaction) { described_class.new(transaction_information).build }

    it 'sets the amount_in_cents' do
      expect(bank_transaction.amount_in_cents).to eq -1139
    end

    it 'sets the bank' do
      expect(bank_transaction.bank).to eq 'AIB'
    end

    it 'sets the datetime' do
      expect(bank_transaction.datetime).to eq DateTime.parse('2021-06-11')
    end

    it 'sets the description' do
      expect(bank_transaction.description).to eq 'DELIVEROO'
    end

    it 'sets the internal_id' do
      expect(bank_transaction.internal_id).to eq 'W00Vi6WZnIL0J4I0ToP2uTjvb3GgCvjKmX4c3'
    end

    it 'sets year_month' do
      expect(bank_transaction.year_month).to eq '2021-06'
    end

    it 'sets day' do
      expect(bank_transaction.day).to eq '11'
    end
  end
end
