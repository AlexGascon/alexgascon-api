# frozen_string_literal: true

RSpec.describe Airtable::CategoryClassifier do
  describe '.category_id_for' do
    let(:subscriptions_category) { 'Subscriptions' }
    let(:food_category) { 'Bar / Restaurant' }
    let(:unclassified_category) { 'Sin clasificar' }

    it 'matches Netflix' do
      transaction = create(:netflix_expense)

      expect(described_class.category_id_for(transaction)).to eq subscriptions_category
    end

    it 'matches Spotify' do
      transaction = create(:spotify_expense)

      expect(described_class.category_id_for(transaction)).to eq subscriptions_category
    end

    it 'matches Pepephone' do
      transaction = create(:pepephone_expense)

      expect(described_class.category_id_for(transaction)).to eq subscriptions_category
    end

    it 'matches Deliveroo monthly fee as subscription' do
      transaction = create(:deliveroo_subscription)

      expect(described_class.category_id_for(transaction)).to eq subscriptions_category
    end

    it 'matches Deliveroo expense as food' do
      transaction = create(:deliveroo_expense)

      expect(described_class.category_id_for(transaction)).to eq food_category
    end

    it 'returns Undefined category when no rules match' do
      transaction = create(:unclassified_expense)

      expect(described_class.category_id_for(transaction)).to eq unclassified_category
    end
  end
end
