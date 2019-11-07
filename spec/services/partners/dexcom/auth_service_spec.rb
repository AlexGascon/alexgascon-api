# frozen_string_literal: true

RSpec.describe Partners::Dexcom::AuthService do
    let(:mock_dexcom_credentials) do
      {
        DEXCOM_URL: 'https://api.dexcom.com',
        DEXCOM_CLIENT_ID: 'client_id',
        DEXCOM_CLIENT_SECRET: 'client_secret',
        DEXCOM_REDIRECT_URI: 'www.example.com/dexcom'
      }
    end

    let(:mock_headers) { { 'Content-Type' => 'application/x-www-form-urlencoded' } }
    let(:base_payload) do
      {
        client_id: 'client_id',
        client_secret: 'client_secret',
        redirect_uri: 'www.example.com/dexcom'
      }
    end

    before do
      @stub = stub_request(:post, 'https://api.dexcom.com/v2/oauth2/token')
              .with(headers: mock_headers, body: mock_request_body)
              .to_return(status: 200, body: mock_response.to_json)

      travel_to Time.new(2018, 10, 30, 12, 34, 56)
    end

    around { |example| with_modified_env(mock_dexcom_credentials) { example.run } }

    after { travel_back }

  describe '#obtain_oauth_token' do
    let(:mock_request_body) { base_payload.merge(code: '1234', grant_type: 'authorization_code') }

    let(:mock_response) do
      {
        'access_token': 'example_access_token',
        'expires_in': 7200,
        'token_type': 'Bearer',
        'refresh_token': 'example_refresh_token'
      }
    end

    before do
      @stub = stub_request(:post, 'https://api.dexcom.com/v2/oauth2/token')
              .with(headers: mock_headers, body: mock_request_body)
              .to_return(status: 200, body: mock_response.to_json)
    end

    subject { described_class.new.obtain_oauth_token('1234') }

    it 'requests the access token to Dexcom' do
      subject

      expect(@stub).to have_been_requested
    end

    it 'stores the access token information' do
      token = subject

      expected_attributes = {
        access_token: 'example_access_token',
        expiration_time: Time.new(2018, 10, 30, 14, 34, 56).to_i,
        refresh_token: 'example_refresh_token'
      }
      expect(token).to have_attributes expected_attributes
    end
  end

  describe '#renew_oauth_token' do
    let(:mock_request_body) { base_payload.merge(refresh_token: '5678', grant_type: 'refresh_token') }

    let(:mock_response) do
      {
        'access_token': 'example_new_access_token',
        'expires_in': 3600,
        'token_type': 'Bearer',
        'refresh_token': 'example_new_refresh_token'
      }
    end

    before do
      Partners::Dexcom::AuthToken.instance
      .update_attributes(refresh_token: '5678')
    end

    subject { described_class.new.renew_oauth_token }

    it 'requests the token renewal to Dexcom' do
      subject

      expect(@stub).to have_been_requested
    end

    it 'stores the renewed token information' do
      token = subject

      expected_attributes = {
        access_token: 'example_new_access_token',
        expiration_time: Time.new(2018, 10, 30, 13, 34, 56).to_i,
        refresh_token: 'example_new_refresh_token'
      }
      expect(token).to have_attributes expected_attributes
    end
  end
end
