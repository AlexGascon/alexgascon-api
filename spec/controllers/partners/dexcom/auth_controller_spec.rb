# frozen_string_literal: true

RSpec.describe Partners::Dexcom::AuthController do
  describe '#auth_callback' do
    let(:authorization_code) { 'auth_code_123' }
    let(:auth_service) { instance_double(Partners::Dexcom::AuthService) }

    before do
      allow(Partners::Dexcom::AuthService).to receive(:new).and_return(auth_service)
      allow(auth_service).to receive(:obtain_oauth_token)
    end

    subject { get '/dexcom/auth_callback', query: { code: authorization_code } }

    it 'returns an HTTP 200 OK response' do
      subject

      expect(response.status).to eq 200
    end

    it 'obtains the OAuth token' do
      expect(auth_service).to receive(:obtain_oauth_token)

      subject
    end

    context 'when the authorization code is not present' do
      let(:authorization_code) { nil }

      it 'returns an HTTP 401 Unauthorized response' do
        subject

        expect(response.status).to eq 401
      end
    end
  end
end
