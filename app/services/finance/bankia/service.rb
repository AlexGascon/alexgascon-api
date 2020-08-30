# frozen_string_literal: true

module Finance
  module Bankia
    class Service
      FINTONIC_VERSION = 'application/vnd.fintonic-v7+json'

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

        # Note: when there are no transactions for the specified date range, Fintonic
        # returns transactions anyway. To avoid propagating them, we'll make sure
        # that we are selecting transactions in the specified range
        response
          .yield_self { |r| JSON.parse(r .body) }
          .dig('resultList')
          .select { |transaction| correct_date_range?(transaction, from, to) }
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

      def transactions_endpoint
        "#{base_url}/finapi/rest/transaction/listByBank/2038"
      end

      def base_url
        @base_url ||= ENV['FINTONIC_URL']
      end

      def transactions_headers
        {
          'device-uuid': device_uuid,
          'Accept': FINTONIC_VERSION,
          'Authorization': "Bearer #{@auth_token}"
        }
      end

      def transactions_payload(from, to)
        from_formatted = from.strftime('%Y-%m-%d')
        to_formatted = to.strftime('%Y-%m-%d')

        {
          pageLimit: 25,
          startDate: from_formatted,
          endDate: to_formatted,
          pageOffset: 0
        }
      end

      def correct_date_range?(transaction, from, to)
        transaction_date = Date.parse(transaction.dig('userDate'))
        date_range = from..to

        date_range.cover? transaction_date
      end

      def authenticate
        response = HTTParty.post(auth_endpoint, headers: auth_headers, body: auth_payload.to_json)
        response_body = JSON.parse(response.body)

        @auth_token = response_body.dig('data', 'access_token')
      end

      def auth_endpoint
        "#{base_url}/finapi/oidc/token"
      end

      def auth_headers
        {
          'Accept' => FINTONIC_VERSION,
          'Content-Type' => 'application/json',
        }
      end

      def auth_payload
        {
          username: username,
          password: password,
          deviceUUID: device_uuid
        }
      end

      def username
        @username ||= ENV['FINTONIC_USERNAME']
      end

      def password
        @password ||= ENV['FINTONIC_PASSWORD']
      end

      def device_uuid
        @device_uuid ||= ENV['FINTONIC_DEVICE_UUID']
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

      def handle_request_error(response)
        Jets.logger.warn "Error in #{self.class}: Non-200 status code received: #{response.code}"
        @request_error = true
      end

      def handle_exception(exception)
        @exception = true
      end

      def base_bankia_metric
        metric = Metrics::BaseMetric.new
        metric.namespace = "#{Metrics::Namespaces::INFRASTRUCTURE}/#{Metrics::Namespaces::FINANCE}"
        metric.unit = Metrics::Units::COUNT
        metric.timestamp = DateTime.now
        metric.dimensions = [{ name: 'Bank', value: 'Bankia' }]

        metric
      end

      def publish_metrics
        retry_metric = base_bankia_metric
        retry_metric.metric_name = 'get_transactions retries'
        retry_metric.value = @retries

        request_error_metric = base_bankia_metric
        request_error_metric.metric_name = 'Request transactions error'
        request_error_metric.value = @request_error ? 1 : 0

        exception_metric = base_bankia_metric
        exception_metric.metric_name = 'Exception'
        exception_metric.value = @exception ? 1 : 0

        PublishCloudwatchDataCommand.new(retry_metric).execute
        PublishCloudwatchDataCommand.new(request_error_metric).execute
        PublishCloudwatchDataCommand.new(exception_metric).execute
      end
    end
  end
end
