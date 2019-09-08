# frozen_string_literal: true

RSpec.describe Partners::Dexcom::AuthController do
  describe '#auth_callback' do
    let(:authorization_code) { 'auth_code_123' }

    subject { get '/dexcom/auth_callback', query: { authorization_code: authorization_code } }

    it 'returns an HTTP 200 OK response' do
      subject

      expect(response.status).to eq 200
    end
  end
end
