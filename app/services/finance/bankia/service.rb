# frozen_string_literal: true

module Finance
  module Bankia
    class Service
      FINTONIC_VERSION = 'application/vnd.fintonic-v7+json'

      MAX_RETRIES = 3

      def initialize
        @retries = 0
      end

      def get_transactions(from, to = nil)
        to ||= from

        authenticate unless @auth_token

        response = request_transactions(from, to)

        if response.unauthorized?
          authenticate
          response = request_transactions(from, to)
        end

        # Note: when there are no movements for the specified date range, Fintonic
        # returns movements anyway. To mimic this behavior, we'll return a
        # response with movements on dates differents to the specified
        response
          .yield_self { |r| JSON.parse(r .body) }
          .dig('resultList')
          .select { |transaction| correct_date_range?(transaction, from, to) }
      rescue EOFError
        Jets.logger.warn "Error while retrieving bank transactions, retrying... Retry #: #{@retries}"

        @retries += 1
        retry unless @retries > MAX_RETRIES

        Jets.logger.error('No more retries left, aborting')
        []
      ensure
        publish_retry_metric
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

      def publish_retry_metric
        retry_metric = Metrics::BaseMetric.new
        retry_metric.namespace = "#{Metrics::Namespaces::INFRASTRUCTURE}/#{Metrics::Namespaces::FINANCE}/Fintonic"
        retry_metric.metric_name = 'get_transactions retries'
        retry_metric.unit = Metrics::Units::COUNT
        retry_metric.value = @retries
        retry_metric.timestamp = DateTime.now
        retry_metric.dimensions = []

        PublishCloudwatchDataCommand.new(retry_metric).execute
      end
    end
  end
end
