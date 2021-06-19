# frozen_string_literal: true

RSpec.shared_examples 'auth error metric' do |metric_value|
  it "emits an auth error metric with value #{metric_value}" do
    auth_error_metric = Metrics::BaseMetric.new
    auth_error_metric.namespace = 'Infrastructure/Finance'
    auth_error_metric.metric_name = 'Auth error'
    auth_error_metric.unit = 'Count'
    auth_error_metric.value = metric_value
    auth_error_metric.timestamp = Time.new(2020, 8, 1, 12, 34, 56)
    auth_error_metric.dimensions = [{ name: 'Bank', value: 'AIB' }]

    expect(PublishCloudwatchDataCommand).to receive(:new).with(auth_error_metric)

    subject
  end
end

RSpec.shared_examples 'request error metric' do |metric_value|
  it "emits a request error metric with value #{metric_value}" do
    request_error_metric = Metrics::BaseMetric.new
    request_error_metric.namespace = 'Infrastructure/Finance'
    request_error_metric.metric_name = 'Request transactions error'
    request_error_metric.unit = 'Count'
    request_error_metric.value = metric_value
    request_error_metric.timestamp = Time.new(2020, 8, 1, 12, 34, 56)
    request_error_metric.dimensions = [{ name: 'Bank', value: 'AIB' }]

    expect(PublishCloudwatchDataCommand).to receive(:new).with(request_error_metric)

    subject
  end
end

RSpec.shared_examples 'exception metric' do |metric_value|
  it "emits a general error metric with value #{metric_value}" do
    general_error_metric = Metrics::BaseMetric.new
    general_error_metric.namespace = 'Infrastructure/Finance'
    general_error_metric.metric_name = 'Exception'
    general_error_metric.unit = 'Count'
    general_error_metric.value = metric_value
    general_error_metric.timestamp = Time.new(2020, 8, 1, 12, 34, 56)
    general_error_metric.dimensions = [{ name: 'Bank', value: 'AIB' }]

    expect(PublishCloudwatchDataCommand).to receive(:new).with(general_error_metric)

    subject
  end
end

RSpec.describe Finance::Aib::Service do
  let(:credentials) do
    {
      PLAID_ACCESS_TOKEN: 'access-development-12345678-9abc-deff-edcb-a98765432100'
    }
  end
  let(:transactions_get_request) do
    Plaid::TransactionsGetRequest.new(
      access_token: 'access-development-12345678-9abc-deff-edcb-a98765432100',
      start_date: '2020-07-31',
      end_date: '2020-08-01'
    )
  end

  before do
    travel_to Time.new(2020, 8, 1, 12, 34, 56)
    allow_any_instance_of(Plaid::PlaidApi)
      .to receive(:transactions_get)
      .with(
        fields_with_values(start_date: '2020-07-31', end_date: '2020-08-01', access_token: 'defaultFactoryAccessToken')
        .and be_a_kind_of(Plaid::TransactionsGetRequest)
      )
      .and_return(transactions_get_response)
    stub_command PublishCloudwatchDataCommand
  end

  around { |example| with_modified_env(credentials) { example.run } }

  after do
    travel_back
  end

  subject { described_class.new.get_transactions(Time.now.yesterday, Time.now) }

  describe 'get_transactions' do
    let(:transactions_get_response) { build(:plaid_transactions_get_response) }

    context 'when a valid token exists' do
      before { FactoryBot.create(:aib_token, expiration_time: Time.now.to_i + 200) }

      it 'retrieves the bank movements' do
        expect(subject.first).to eq build(:plaid_transaction)
      end

      include_examples 'auth error metric', 0

      include_examples 'request error metric', 0

      include_examples 'exception metric', 0

      context 'when there are no bank movements' do
        let(:transactions_get_response) { build(:plaid_transactions_get_response, transactions: [], total_transactions: 0) }

        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end

      context 'when we get an exception' do
        before do
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

      context 'when Plaid returns an Auth error' do
        let(:plaid_auth_error) do
          Plaid::ApiError.new(
            code: 400,
            response_headers: { 'server'=>'nginx', 'date'=>'Wed, 16 Jun 2021 22:16:30 GMT', 'content-type'=>'application/json; charset=utf-8', 'content-length'=>'277', 'connection'=>'keep-alive', 'plaid-version'=>'2020-09-14', 'vary'=>'Accept-Encoding' },
            response_body: "{\n  \"display_message\": null,\n  \"documentation_url\": \"https://plaid.com/docs/?ref=error#invalid-input-errors\",\n  \"error_code\": \"INVALID_ACCESS_TOKEN\",\n  \"error_message\": \"could not find matching access token\",\n  \"error_type\": \"INVALID_INPUT\",\n  \"request_id\": \"A8FB4xip7LVjlMs\",\n  \"suggested_action\": null\n}"
          )
        end

        before do
          allow_any_instance_of(Plaid::PlaidApi)
            .to receive(:transactions_get)
            .with(
              fields_with_values(start_date: '2020-07-31', end_date: '2020-08-01', access_token: 'defaultFactoryAccessToken')
              .and be_a_kind_of(Plaid::TransactionsGetRequest)
            ).and_raise plaid_auth_error
        end

        it 'returns an empty array' do
          expect(subject).to eq []
        end

        include_examples 'auth error metric', 1

        include_examples 'request error metric', 0

        include_examples 'exception metric', 0
      end
    end

    context 'when the access token has expired' do
      before do
        FactoryBot.create(:aib_token, expiration_time: Time.now.to_i - 200)
      end

      it 'returns an empty array' do
        expect(subject).to eq []
      end

      include_examples 'auth error metric', 1

      include_examples 'request error metric', 0

      include_examples 'exception metric', 0
    end
  end
end
