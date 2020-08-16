# frozen_string_literal: true

RSpec.describe Finance::Aib::Service do
  let(:truelayer_credentials) do
    {
      TRUELAYER_AIB_ACCOUNT_ID: '123456789009876543212',
      TRUELAYER_BASE_URL: 'fake-truelayer.com',
      TRUELAYER_CLIENT_ID: 'myclientid-1234ab',
      TRUELAYER_CLIENT_SECRET: 'e9f9a53e-9db9-4707-aaa7-c9a117b4d12c',
      TRUELAYER_REDIRECT_URL: 'https://redirect.fake-truelayer.com/redirect'
    }
  end

  let(:content_type_json) { { 'Content-Type'=> 'application/json' } }

  before do
    travel_to Time.new(2020, 8, 1, 12, 34, 56)
    stub_command PublishCloudwatchDataCommand
  end

  around { |example| with_modified_env(truelayer_credentials) { example.run } }

  after do
    travel_back
  end

  subject { described_class.new.get_transactions(Date.yesterday, Date.today) }

  describe 'get_transactions' do
    let(:get_transactions_request) do
      stub_request(:get, 'https://api.fake-truelayer.com/data/v1/accounts/123456789009876543212/transactions')
      .with(
        headers: { 'Authorization' => 'Bearer defaultFactoryAccessToken' },
        query: { from: '2020-07-31', to: '2020-08-01'}
      )
    end
    let(:get_transactions_response) { load_json_fixture 'finance/truelayer/aib_transactions_response' }


    context 'when a valid token exists' do
      before do
        FactoryBot.create(:aib_token, expiration_time: Time.now.to_i + 200)
        get_transactions_request.to_return(status: 200, body: get_transactions_response.to_json, headers: content_type_json)
      end

      it 'retrieves the bank movements' do
        expected_movements = load_json_fixture('finance/truelayer/aib_transactions')
        expect(subject).to eq expected_movements
      end

      context 'when there are no bank movements' do
        let(:get_transactions_response) { load_json_fixture 'finance/truelayer/no_transactions' }

        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
    end

    context 'when the access token has expired' do
      before do
        FactoryBot.create(:aib_token, expiration_time: Time.now.to_i - 200)
        get_transactions_request.to_return(status: 401)
      end

      let(:refresh_token_payload) do
        {
          client_id: 'myclientid-1234ab', client_secret: 'e9f9a53e-9db9-4707-aaa7-c9a117b4d12c',
          grant_type: 'refresh_token', refresh_token: 'defaultFactoryRefreshToken'
        }
      end
      let(:refresh_token_ok_response) do
        {
          access_token: 'refreshedSuperLongAndRandomAccessTokenReturnedByTruelayer', expire_in: '60',
          refresh_token: 'my-second-refresh-token', token_type: 'Bearer'
        }
      end
      let(:refresh_token_request) do
        stub_request(:post, 'https://auth.fake-truelayer.com/connect/token')
        .with(
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: refresh_token_payload
        )
      end
      let(:get_transactions_request_with_refreshed_token) do
        stub_request(:get, 'https://api.fake-truelayer.com/data/v1/accounts/123456789009876543212/transactions')
        .with(
          headers: { 'Authorization' => 'Bearer refreshedSuperLongAndRandomAccessTokenReturnedByTruelayer' },
          query: { from: '2020-07-31', to: '2020-08-01'}
        )
      end

      context 'when the token renewal is successful' do
        before do
          refresh_token_request.to_return(status: 200, body: refresh_token_ok_response.to_json, headers: content_type_json)
          get_transactions_request_with_refreshed_token.to_return(status: 200, body: get_transactions_response.to_json, headers: content_type_json)
        end

        it 'refreshes the token' do
          subject

          expect(refresh_token_request).to have_been_requested
        end

        it 'retries the operation' do
          subject

          expect(get_transactions_request_with_refreshed_token).to have_been_requested
        end
      end

      context 'when refreshing the token fails' do
        before do
          refresh_token_request.to_return(status: 400)
        end

        it 'emits an error metric' do
          auth_error_metric = Metrics::BaseMetric.new
          auth_error_metric.namespace = "Infrastructure/Finance/AIB"
          auth_error_metric.metric_name = 'Auth error'
          auth_error_metric.unit = 'Count'
          auth_error_metric.value = 1
          auth_error_metric.timestamp = Time.new(2020, 8, 1, 12, 34, 56)
          auth_error_metric.dimensions = []

          expect(PublishCloudwatchDataCommand).to receive(:new).with(auth_error_metric)
          subject
        end

        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
    end
  end
end
