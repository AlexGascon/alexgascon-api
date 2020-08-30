# frozen_string_literal: true

RSpec.shared_examples 'request error metric' do |metric_value|
  it "emits an request error metric with value #{metric_value}" do
    request_error_metric = Metrics::BaseMetric.new
    request_error_metric.namespace = 'Infrastructure/Finance'
    request_error_metric.metric_name = 'Request transactions error'
    request_error_metric.unit = 'Count'
    request_error_metric.value = metric_value
    request_error_metric.timestamp = Time.new(2020, 5, 3, 12, 34, 56)
    request_error_metric.dimensions = [{ name: 'Bank', value: 'Openbank' }]

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
    exception_metric.dimensions = [{ name: 'Bank', value: 'Openbank' }]

    expect(PublishCloudwatchDataCommand).to receive(:new).with(exception_metric)

    subject
  end

end

RSpec.describe Finance::Openbank::Service do
  let(:openbank_credentials) do
    {
      OPENBANK_URL: 'https://fake.openbank.es',
      OPENBANK_CONTRACT_NUMBER: '99',
      OPENBANK_DOCUMENT: '30376334G',
      OPENBANK_PASSWORD: '1234'
    }
  end

  let(:auth_payload) { { document: '30376334G', password: '1234', documentType: 'N', force: true } }
  let(:auth_response) { { tokenCredential: 'myToken', application: 'api' } }

  let(:movements_payload) { { producto: '055', numeroContrato: 99, fechaDesde: '2020-05-02', fechaHasta: '2020-05-02' } }

  let(:content_type_header) { { 'Content-Type'=> 'application/json' } }

  let(:auth_request) do
    stub_request(:post, 'https://fake.openbank.es/authenticationcomposite/login')
      .with(body: auth_payload)
  end
  let(:movements_request) do
    stub_request(:get, 'https://fake.openbank.es/my-money/cuentas/movimientos')
      .with(query: movements_payload)
  end

  let(:retries_metric) do
    retry_metric = Metrics::BaseMetric.new
    retry_metric.namespace = "Infrastructure/Finance/Openbank"
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

  around { |example| with_modified_env(openbank_credentials) { example.run } }

  after { travel_back }

  subject { described_class.new.get_transactions(Date.yesterday) }

  describe 'get_transactions' do
    context 'when everything goes fine' do
      let(:movements_response) { load_json_fixture 'finance/openbank/get_movements_response' }

      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: content_type_header)
        movements_request.to_return(status: 200, body: movements_response.to_json, headers: content_type_header)
      end

      it 'retrieves the bank movements' do
        expected_response = load_json_fixture('finance/openbank/movements')

        result = subject
        expect(result).to eq expected_response
      end

      include_examples 'retry metric', 0

      include_examples 'request error metric', 0

      include_examples 'exception metric', 0
    end

    context 'when there are no new movements' do
      let(:movements_response) { load_json_fixture 'finance/openbank/no_movements' }

      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: content_type_header)
        movements_request.to_return(status: 404, body: movements_response.to_json, headers: content_type_header)
      end

      include_examples 'returns an empty array'

      include_examples 'retry metric', 0

      include_examples 'request error metric', 0

      include_examples 'exception metric', 0
    end

    context 'when we get a Bad Request response' do
      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: content_type_header)
        movements_request.to_return(status: 400, body: {}.to_json, headers: content_type_header)
      end

      include_examples 'returns an empty array'

      include_examples 'retry metric', 0

      include_examples 'request error metric', 1

      include_examples 'exception metric', 0
    end

    context 'when we get an exception' do
      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: content_type_header)
        movements_request.to_return(status: 200)

        allow_any_instance_of(described_class)
          .to receive(:request_transactions)
          .and_raise StandardError.new('Everything exploded very badly')
      end

      it 'returns an empty array' do
        expect(subject).to eq []
      end

      include_examples 'request error metric', 0

      include_examples 'exception metric', 1
    end

    context 'when the request timeouts when reading' do
      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: content_type_header)
        movements_request.to_raise(EOFError)
      end

      it 'retries 3 times' do
        subject

        expect(movements_request).to have_been_made.times(4)
      end

      include_examples 'returns an empty array'

      include_examples 'retry metric', 4

      include_examples 'request error metric', 0

      include_examples 'exception metric', 1
    end
  end
end
