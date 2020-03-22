# frozen_string_literal: true

RSpec.describe Partners::Dexcom::AuthToken do
  describe '.instance' do
    context 'if the token has not been created yet' do
      before do
        described_class.delete_table
        described_class.create_table
      end

      it 'creates a new token' do
        expect { described_class.instance.save }.to change { described_class.count }.by(1)
      end
    end

    context 'if a token already exists' do
      before { described_class.instance.save }

      it 'always returns the same instance' do
        expect(described_class.instance.id).to eq(described_class.instance.id)
      end

      it 'does not create new tokens' do
        expect { described_class.instance.save }.not_to(change { described_class.count })
      end
    end
  end

  describe '.new' do
    it 'is marked as private' do
      skip 'Dynamoid calls .new when doing first, last and other methods; look for a workaround'
      expect { described_class.new }.to raise_error(NoMethodError)
    end
  end
end
