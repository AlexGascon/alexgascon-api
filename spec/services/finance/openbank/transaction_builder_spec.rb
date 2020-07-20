# frozen_string_literal: true

RSpec.describe Finance::Openbank::TransactionBuilder do
  let(:transaction_information) { load_json_fixture 'finance/openbank/movement' }

  describe '#build' do
    subject(:bank_transaction) { described_class.new(transaction_information).build }

    it 'sets the amount_in_cents' do
      expect(bank_transaction.amount_in_cents).to eq -999
    end

    it 'sets the bank' do
      expect(bank_transaction.bank).to eq 'Openbank'
    end

    it 'sets the datetime' do
      expect(bank_transaction.datetime).to eq Date.parse('2020-03-03')
    end

    it 'sets the description' do
      expect(bank_transaction.description).to eq 'COMPRA EN PAYPAL *DAZN, CON LA TARJETA : XXXXXXXXXXXX4205 EL 2020-03-02'
    end

    it 'sets the internal_id' do
      expect(bank_transaction.internal_id).to eq 'BH027_10226'
    end

    it 'sets year_month' do
      expect(bank_transaction.year_month).to eq '2020-03'
    end

    it 'sets day' do
      expect(bank_transaction.day).to eq '03'
    end
  end
end
