# frozen_string_literal: true

RSpec.describe Ynab::CategoryClassifier do
  describe 'category_id_for' do
    it 'matches Netflix' do
      transaction = create(:netflix_expense)
      category_id = '74f10f52-e1fe-4110-8b36-30576247af9d'

      expect(described_class.category_id_for(transaction)).to eq category_id
    end

    it 'matches Spotify' do
      transaction = create(:spotify_expense)
      category_id = 'f28af6ef-5561-4deb-8443-ddc902cf9acd'

      expect(described_class.category_id_for(transaction)).to eq category_id
    end

    it 'matches Pepephone' do
      transaction = create(:pepephone_expense)
      category_id = '19dbeac9-1ab4-460d-9aff-d014f78bd10e'

      expect(described_class.category_id_for(transaction)).to eq category_id
    end

    it 'matches Deliveroo monthly fee as subscription' do
      transaction = create(:deliveroo_subscription)
      category_id = '468a2de5-10e8-432e-8a16-7221f2ac4590'

      expect(described_class.category_id_for(transaction)).to eq category_id
    end

    it 'matches Deliveroo expense as food' do
      transaction = create(:deliveroo_expense)
      category_id = 'c494b8b4-a82c-4ba7-941e-b3ee811206ab'

      expect(described_class.category_id_for(transaction)).to eq category_id
    end

    it 'matches Tesco expenses' do
      transaction = create(:tesco_expense)
      category_id = '2b65b6fd-25f0-42cc-9664-1c4cc61812a7'

      expect(described_class.category_id_for(transaction)).to eq category_id
    end

    it 'matches Mercadona expenses' do
      transaction = create(:mercadona_expense)
      category_id = '2b65b6fd-25f0-42cc-9664-1c4cc61812a7'

      expect(described_class.category_id_for(transaction)).to eq category_id
    end

    it 'returns Undefined category when no rules match' do
      transaction = create(:unclassified_expense)
      uncategorized_id = 'e172c064-eb5c-4fb2-9bd7-ae5fe9af692f'

      expect(described_class.category_id_for(transaction)).to eq uncategorized_id
    end
  end
end
