# frozen_string_literal: true

module Finance
  module Openbank
    class Service
      DOCUMENT_TYPE = 'N'
      PRODUCT_ID = '055'

      MAX_RETRIES = 3

      def get_transactions(from, to = nil)
        to ||= from

        authenticate unless @auth_token

        response = request_transactions(from, to)

        if response.unauthorized?
          authenticate
          response = request_transactions(from, to)
        end

        response['movimientos']
      rescue EOFError
        Jets.logger.warn "Error while retrieving bank transactions, retrying... Retry #: #{retries}"

        retry if retries < MAX_RETRIES

        Jets.logger.error('No more retries left, aborting')
      end

      private

      def request_transactions(from, to)
        HTTParty.get(
          transactions_endpoint,
          headers: transactions_headers,
          query: transactions_payload(from, to)
        )
      end

      def base_url
        @base_url ||= ENV['OPENBANK_URL']
      end

      def transactions_endpoint
        "#{base_url}/my-money/cuentas/movimientos"
      end

      def transactions_headers
        { 'openBankAuthToken' => @auth_token }
      end

      def transactions_payload(from, to)
        from_formatted = from.strftime('%Y-%m-%d')
        to_formatted = to.strftime('%Y-%m-%d')

        {
          'producto' => PRODUCT_ID,
          'numeroContrato' => ENV['OPENBANK_CONTRACT_NUMBER'],
          'fechaDesde' => from_formatted,
          'fechaHasta' => to_formatted
        }
      end

      def retries
        @retries ||= 0
      end

      def authenticate
        response = HTTParty.post(auth_endpoint, headers: auth_headers, body: auth_payload.to_json)
        response_body = JSON.parse(response.body)

        @auth_token = response_body['tokenCredential']
      end

      def auth_endpoint
        "#{base_url}/authenticationcomposite/login"
      end

      def auth_headers
        { 'Content-Type' => 'application/json' }
      end

      def auth_payload
        {
          'document' => ENV['OPENBANK_DOCUMENT'],
          'password' => ENV['OPENBANK_PASSWORD'],
          'documentType' => DOCUMENT_TYPE,
          'force' => true
        }
      end
    end
  end
end
