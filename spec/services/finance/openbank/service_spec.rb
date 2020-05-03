# frozen_string_literal: true

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

  before do
    travel_to Time.new(2020, 5, 3, 12, 34, 56)
  end

  around { |example| with_modified_env(openbank_credentials) { example.run } }

  after { travel_back }

  subject { described_class.new }

  describe 'get_transactions' do
    context 'when everything goes fine' do
      let(:movements_response) { load_json_fixture 'finance/openbank/get_movements_response' }

      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: content_type_header)
        movements_request.to_return(status: 200, body: movements_response.to_json, headers: content_type_header)
      end

      it 'retrieves the bank movements' do
        expected_response = load_json_fixture('finance/openbank/movements')

        result = subject.get_transactions(Date.yesterday)
        expect(result).to eq expected_response
      end
    end

    context 'when there are no new movements' do
      let(:movements_response) { load_json_fixture 'finance/openbank/no_movements' }

      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: content_type_header)
        movements_request.to_return(status: 404, body: movements_response.to_json, headers: content_type_header)
      end

      it 'returns an empty array' do
        result = subject.get_transactions(Date.yesterday)
        expect(result).to eq []
      end
    end

    context 'when the request timeouts when reading' do
      before do
        auth_request.to_return(status: 200, body: auth_response.to_json, headers: content_type_header)
        movements_request.to_raise(EOFError)
      end

      it 'retries 3 times' do
        subject.get_transactions(Date.yesterday)

        expect(movements_request).to have_been_made.times(4)
      end

      it 'returns an empty array' do
        result = subject.get_transactions(Date.yesterday)
        expect(result).to eq []
      end
    end
  end
end
