# frozen_string_literal: true

RSpec.describe Partners::Dexcom::AuthController do
  describe '#auth_callback' do
    let(:authorization_code) { 'auth_code_123' }

    subject { get '/dexcom/auth_callback', query: { authorization_code: authorization_code } }

    it 'returns an HTTP 200 OK response' do
      subject

      expect(response.status).to eq 200
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
