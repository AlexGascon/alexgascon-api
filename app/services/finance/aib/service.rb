# frozen_string_literal: true

module Finance
  module Aib
    class AuthError < StandardError; end
    ERROR_INVALID_ACCESS_TOKEN = 'INVALID_ACCESS_TOKEN'

    class Service
      def initialize
        @auth_error = false
        @request_error = false
        @exception = false
      end

      def get_transactions(from, to = nil)
        to ||= from

        authenticate

        response = request_transactions(from, to)

        response.transactions
      rescue Finance::Aib::AuthError => e
        handle_error(e, :auth)
      rescue Plaid::ApiError => e
        handle_error(e, :request)
      rescue StandardError => e
        handle_error(e, :exception)
      ensure
        publish_metrics
      end

      private

      def request_transactions(from, to)
        from = from.strftime('%Y-%m-%d')
        to = to.strftime('%Y-%m-%d')

        request_data = Plaid::TransactionsGetRequest.new(
          access_token: @auth_token,
          start_date: from,
          end_date: to
        )

        plaid_client = Finance::PlaidClientFactory.build
        plaid_client.transactions_get(request_data)
      end

      def authenticate
        @auth_token = AuthToken.token_for(AuthToken::PROVIDER_AIB)

        validate_auth_token!

        @auth_token
      end

      def validate_auth_token!
        raise Finance::Aib::AuthError, 'The AuthToken is empty' if @auth_token.access_token.nil?
        raise Finance::Aib::AuthError, 'AuthToken expired' if Time.at(@auth_token.expiration_time).past?
      end

      def handle_error(additional_data, error_type)
        case error_type
        when :auth
          handle_auth_error(additional_data)
        when :request
          error_body = JSON.parse(additional_data.response_body)

          if error_body['error_code'] == ERROR_INVALID_ACCESS_TOKEN
            handle_auth_error(additional_data)
          else
            handle_request_error(additional_data)
          end
        when :exception
          handle_exception(additional_data)
        end

        []
      end

      def handle_auth_error(exception)
        Jets.logger.warn "Error in #{self.class}: Authentication error: #{exception.message}"
        @auth_error = true
      end

      def handle_request_error(response)
        Jets.logger.warn "Error in #{self.class}: Non-200 status code received: #{response.code}"
        @request_error = true
      end

      def handle_exception(exception)
        Jets.logger.warn "Error in #{self.class}: #{exception.message}"
        @exception = true
      end

      def base_aib_metric
        metric = Metrics::BaseMetric.new
        metric.namespace = "#{Metrics::Namespaces::INFRASTRUCTURE}/#{Metrics::Namespaces::FINANCE}"
        metric.unit = Metrics::Units::COUNT
        metric.timestamp = DateTime.now
        metric.dimensions = [{ name: 'Bank', value: 'AIB' }]

        metric
      end

      def publish_metrics
        auth_error_metric = base_aib_metric
        auth_error_metric.metric_name = 'Auth error'
        auth_error_metric.value = @auth_error ? 1 : 0

        request_error_metric = base_aib_metric
        request_error_metric.metric_name = 'Request transactions error'
        request_error_metric.value = @request_error ? 1 : 0

        error_metric = base_aib_metric
        error_metric.metric_name = 'Exception'
        error_metric.value = @exception ? 1 : 0

        PublishCloudwatchDataCommand.new(auth_error_metric).execute
        PublishCloudwatchDataCommand.new(request_error_metric).execute
        PublishCloudwatchDataCommand.new(error_metric).execute
      end
    end
  end
end
