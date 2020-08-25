# frozen_string_literal: true

RSpec.describe Finance::Aib::TransactionBuilder do
  let(:transaction_information) { load_json_fixture 'finance/aib/transaction' }

  describe '#build' do
    subject(:bank_transaction) { described_class.new(transaction_information).build }

    it 'sets the amount_in_cents' do
      expect(bank_transaction.amount_in_cents).to eq -2637
    end

    it 'sets the bank' do
      expect(bank_transaction.bank).to eq 'AIB'
    end

    it 'sets the datetime' do
      expect(bank_transaction.datetime).to eq DateTime.parse('2020-08-11')
    end

    it 'sets the description' do
      expect(bank_transaction.description).to eq 'VDP-AMZNMktplace'
    end

    it 'sets the internal_id' do
      expect(bank_transaction.internal_id).to eq '7ee551d422dfd72ebe2b144396bb280c'
    end

    it 'sets year_month' do
      expect(bank_transaction.year_month).to eq '2020-08'
    end

    it 'sets day' do
      expect(bank_transaction.day).to eq '11'
    end
  end
end
