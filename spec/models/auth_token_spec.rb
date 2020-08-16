# frozen_string_literal: true

RSpec.describe AuthToken do
  describe '.token_for' do
    let(:provider) { AuthToken::PROVIDER_AIB }

    context 'if the token has not been created yet' do
      before do
        described_class.delete_table
        described_class.create_table
      end

      it 'creates a new token' do
        expect { described_class.token_for(provider).save }.to change { described_class.count }.by(1)
      end
    end

    context 'if a token already exists' do
      before { FactoryBot.create(:aib_token) }

      it 'always returns the same instance' do
        expect(described_class.token_for(provider)).to eq(described_class.token_for(provider))
      end

      it 'does not create new tokens' do
        expect { described_class.token_for(provider).save }.not_to(change { described_class.count })
      end
    end

    context 'when the provider is not valid' do
      it 'raises an exception' do
        expect { described_class.token_for(:some_provider) }.to raise_error(InvalidTokenProvider)
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
