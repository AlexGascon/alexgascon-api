# frozen_string_literal: true

RSpec.describe Finance::CategoryClassifier do
  describe '.category_id_for' do
    let(:subscription_category) { 'subscription' }
    let(:food_category) { 'eating out' }

    it 'matches Netflix' do
      transaction = create(:netflix_bank_transaction)

      expect(described_class.category_id_for(transaction)).to eq subscription_category
    end

    it 'matches Spotify' do
      transaction = create(:spotify_bank_transaction)

      expect(described_class.category_id_for(transaction)).to eq subscription_category
    end

    it 'matches Pepephone' do
      transaction = create(:pepephone_bank_transaction)

      expect(described_class.category_id_for(transaction)).to eq subscription_category
    end

    it 'matches Deliveroo monthly fee as subscription' do
      transaction = create(:deliveroo_subscription_bank_transaction)

      expect(described_class.category_id_for(transaction)).to eq subscription_category
    end

    it 'matches Deliveroo expense as food' do
      transaction = create(:deliveroo_expense_bank_transaction)

      expect(described_class.category_id_for(transaction)).to eq food_category
    end
  end
end
