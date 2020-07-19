# frozen_string_literal: true

RSpec.describe Finance::Bankia::TransactionBuilder do
  let(:transaction_information) { load_json_fixture 'finance/fintonic/bankia_movement' }

  describe '#build' do
    subject(:bank_transaction) { described_class.new(transaction_information).build }

    it 'sets the amount_in_cents' do
      expect(bank_transaction.amount_in_cents).to eq -171
    end

    it 'sets the bank' do
      expect(bank_transaction.bank).to eq 'Bankia'
    end

    it 'sets the datetime' do
      expect(bank_transaction.datetime).to eq Date.parse('2020-05-02')
    end

    it 'sets the description' do
      expect(bank_transaction.description).to eq 'Kindle Svcs*N59P04SY5 - Kindle Svcs*N59P04SY5'
    end

    it 'sets the internal_id' do
      expect(bank_transaction.internal_id).to eq '5ebf41844afb2e1e7d3e7ea4'
    end
  end
end
