# frozen_string_literal: true

RSpec.describe Finance::Bankia::Service do
  let(:credentials) do
    {
      FINTONIC_URL: 'https://fake.fintonic.es',
      FINTONIC_USERNAME: 'username@gmail.com',
      FINTONIC_PASSWORD: 'password',
      FINTONIC_DEVICE_UUID: 'ef260964-8040-4fbb-8504-a9030ddef0b5'
    }
  end

  let(:auth_headers) { { 'Accept' => 'application/vnd.fintonic-v7+json', 'Content-Type' => 'application/json' } }
  let(:auth_payload) { { username: 'username@gmail.com', password: 'password', deviceUUID: 'ef260964-8040-4fbb-8504-a9030ddef0b5' } }
  let(:auth_response) { load_json_fixture 'finance/fintonic/auth_response_success' }
  let(:auth_request) do
    stub_request(:post, 'https://fake.fintonic.es/finapi/oidc/token')
      .with(headers: auth_headers, body: auth_payload)
  end

  let(:transactions_headers) { { 'device-uuid' => 'ef260964-8040-4fbb-8504-a9030ddef0b5', 'Accept': 'application/vnd.fintonic-v7+json', 'Authorization': 'Bearer access_token' } }
  let(:transactions_payload) { { startDate: '2020-05-02', endDate: '2020-05-02', pageLimit: 25, pageOffset: 0 } }
  let(:transactions_response) { load_json_fixture 'finance/fintonic/bankia_transactions_response_success' }
  let(:transactions_request) do
    stub_request(:get, 'https://fake.fintonic.es/finapi/rest/transaction/listByBank/2038')
      .with(headers: transactions_headers, query: transactions_payload)
  end

  let(:retries_metric) do
    retry_metric = Metrics::BaseMetric.new
    retry_metric.namespace = "Infrastructure/Finance/Fintonic"
    retry_metric.metric_name = 'get_transactions retries'
    retry_metric.unit = 'Count'
    retry_metric.value = expected_retries
    retry_metric.timestamp = Time.new(2020, 5, 3, 12, 34, 56)
    retry_metric.dimensions = []

    retry_metric
  end

  before do
    travel_to Time.new(2020, 5, 3, 12, 34, 56)
    stub_command PublishCloudwatchDataCommand
  end

  around { |example| with_modified_env(credentials) { example.run } }

  after { travel_back }

  subject { described_class.new.get_transactions(Date.yesterday) }

  describe 'get_transactions' do
    context 'when everything goes fine' do
      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: auth_headers)
        transactions_request.to_return(status: 200, body: transactions_response.to_json)
      end

      it 'retrieves the bank movements' do
        expected_response = load_json_fixture('finance/fintonic/bankia_movements')

        result = subject
        expect(result).to eq expected_response
      end

      include_examples 'retry metric', 0
    end

    context 'when there are no new movements' do
      before do
        # Note: when there are no movements for the specified date range, Fintonic
        # returns movements anyway. To mimic this behavior, we'll return a
        # response with movements on dates differents to the specified
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: auth_headers)
        transactions_request.to_return(status: 200, body: transactions_response.to_json)
      end

      let(:transactions_response) { load_json_fixture 'finance/fintonic/bankia_transactions_response_no_movements' }

      it 'returns an empty array' do
        result = subject
        expect(result).to eq []
      end

      include_examples 'retry metric', 0
    end

    context 'when the request timeouts when reading' do
      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: auth_headers)
        transactions_request.to_raise(EOFError)
      end

      it 'returns an empty array' do
        result = subject
        expect(result).to eq []
      end

      it 'retries 3 times' do
        subject

        expect(transactions_request).to have_been_made.times(4)
      end

      include_examples 'retry metric', 4
    end
  end
end
