# frozen_string_literal: true

RSpec.shared_examples 'request error metric' do |metric_value|
  it "emits an request error metric with value #{metric_value}" do
    request_error_metric = Metrics::BaseMetric.new
    request_error_metric.namespace = 'Infrastructure/Finance'
    request_error_metric.metric_name = 'Request transactions error'
    request_error_metric.unit = 'Count'
    request_error_metric.value = metric_value
    request_error_metric.timestamp = Time.new(2020, 5, 3, 12, 34, 56)
    request_error_metric.dimensions = [{ name: 'Bank', value: 'Bankia' }]

    expect(PublishCloudwatchDataCommand).to receive(:new).with(request_error_metric)

    subject
  end
end

RSpec.shared_examples 'exception metric' do |metric_value|
  it "emits an exception metric with value #{metric_value}" do
    exception_metric = Metrics::BaseMetric.new
    exception_metric.namespace = 'Infrastructure/Finance'
    exception_metric.metric_name = 'Exception'
    exception_metric.unit = 'Count'
    exception_metric.value = metric_value
    exception_metric.timestamp = Time.new(2020, 5, 3, 12, 34, 56)
    exception_metric.dimensions = [{ name: 'Bank', value: 'Bankia' }]

    expect(PublishCloudwatchDataCommand).to receive(:new).with(exception_metric)

    subject
  end

end

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
    retry_metric.namespace = 'Infrastructure/Finance'
    retry_metric.metric_name = 'get_transactions retries'
    retry_metric.unit = 'Count'
    retry_metric.value = expected_retries
    retry_metric.timestamp = Time.new(2020, 5, 3, 12, 34, 56)
    retry_metric.dimensions = [{ name: 'Bank', value: 'Bankia' }]

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

      include_examples 'request error metric', 0

      include_examples 'exception metric', 0
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

      include_examples 'returns an empty array'

      include_examples 'retry metric', 0

      include_examples 'request error metric', 0

      include_examples 'exception metric', 0
    end

    context 'when we get a Bad Request' do
      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: auth_headers)
        transactions_request.to_return(status: 400)
      end

      include_examples 'returns an empty array'

      include_examples 'retry metric', 0

      include_examples 'request error metric', 1

      include_examples 'exception metric', 0
    end

    context 'when the request timeouts when reading' do
      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: auth_headers)
        transactions_request.to_raise(EOFError)
      end

      it 'retries 3 times' do
        subject

        expect(transactions_request).to have_been_made.times(4)
      end

      include_examples 'retry metric', 4

      include_examples 'request error metric', 0

      include_examples 'exception metric', 1
    end
  end
end
