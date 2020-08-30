# frozen_string_literal: true

module Finance
  module Openbank
    class Service
      DOCUMENT_TYPE = 'N'
      PRODUCT_ID = '055'

      MAX_RETRIES = 3

      def initialize
        @retries = 0
        @request_error = false
        @exception = false
      end

      def get_transactions(from, to = nil)
        to ||= from

        authenticate

        response = request_transactions(from, to)

        unless response.ok?
          return handle_error(response, :request)
        end

        response['movimientos']
      rescue EOFError
        Jets.logger.warn "Error while retrieving bank transactions, retrying... Retry #: #{@retries}"
        @retries += 1
        retry unless @retries > MAX_RETRIES

        handle_error({}, :no_more_retries)
      rescue StandardError => e
        handle_error(e, :exception)
      ensure
        publish_metrics
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

      def handle_error(additional_data, error_type)
        case error_type
        when :no_more_retries
          Jets.logger.error('No more retries left, aborting')
          @exception = true
        when :request
          handle_request_error(additional_data)
        when :exception
          handle_exception(additional_data)
        end

        []
      end

      def handle_exception(exception)
        Jets.logger.warn "Error in #{self.class}: #{exception.message}"
        @exception = true
      end

      def handle_request_error(response)
        if response.not_found?
          Jets.logger.info "No new bank transactions"
        else
          Jets.logger.warn "Error in #{self.class}: Non-200 status code received: #{response.code}"
          @request_error = true
        end
      end

      def base_openbank_metric
        metric = Metrics::BaseMetric.new
        metric.namespace = "#{Metrics::Namespaces::INFRASTRUCTURE}/#{Metrics::Namespaces::FINANCE}"
        metric.unit = Metrics::Units::COUNT
        metric.timestamp = DateTime.now
        metric.dimensions = [{ name: 'Bank', value: 'Openbank' }]

        metric
      end

      def publish_metrics
        # Namespace and Dimensions are different for backwards compatibility
        # This metric was created first and we didn't use any convention then 
        retry_metric = Metrics::BaseMetric.new
        retry_metric.namespace = "#{Metrics::Namespaces::INFRASTRUCTURE}/#{Metrics::Namespaces::FINANCE}/Openbank"
        retry_metric.metric_name = 'get_transactions retries'
        retry_metric.unit = Metrics::Units::COUNT
        retry_metric.value = @retries
        retry_metric.timestamp = DateTime.now
        retry_metric.dimensions = []

        request_error_metric = base_openbank_metric
        request_error_metric.metric_name = 'Request transactions error'
        request_error_metric.value = @request_error ? 1 : 0

        exception_metric = base_openbank_metric
        exception_metric.metric_name = 'Exception'
        exception_metric.value = @exception ? 1 : 0

        PublishCloudwatchDataCommand.new(retry_metric).execute
        PublishCloudwatchDataCommand.new(request_error_metric).execute
        PublishCloudwatchDataCommand.new(exception_metric).execute
      end
    end
  end
end
