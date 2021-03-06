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
  end
end
