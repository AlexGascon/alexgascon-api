# frozen_string_literal: true

module Finance
  module Aib
    class AuthError < StandardError; end

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

        unless response.ok?
          return handle_error(response, :request)
        end

        response['results']
      rescue Finance::Aib::AuthError => e
        handle_error(e, :auth)
      rescue StandardError => e
        handle_error(e, :exception)
      ensure
        publish_metrics
      end

      private

      def request_transactions(from, to)
        # AIB uses Irish Standard Time (IST) for its transactions, so in UTC it's
        # 1 hour less. This means that a transaction registered at 00:00 IST
        # will be returned by TrueLayer as belonging to the previous day.
        #
        # To avoid this problem, we'll make the conversion before sending
        # the request to TrueLayer
        #
        # More context: https://github.com/AlexGascon/alexgascon-api/issues/43#issuecomment-678669868
        from = from.to_time.in_time_zone('Europe/Dublin').beginning_of_day.utc
        to = to.to_time.in_time_zone('Europe/Dublin').end_of_day.utc

        HTTParty.get(
          api_endpoint,
          headers: api_headers,
          query: { from: from.iso8601, to: to.iso8601 }
        )
      end

      def api_endpoint
        "https://api.#{ENV['TRUELAYER_BASE_URL']}/data/v1/accounts/#{ENV['TRUELAYER_AIB_ACCOUNT_ID']}/transactions"
      end

      def api_headers
        { 'Authorization' => "Bearer #{@auth_token.access_token}" }
      end

      def authenticate
        @auth_token = AuthToken.token_for(AuthToken::PROVIDER_AIB)

        request_access_token if @auth_token.access_token.nil?
        refresh_access_token if Time.at(@auth_token.expiration_time).past?

        @auth_token
      end

      def request_access_token
        if @auth_token.authorization_code.nil?
          raise Finance::Aib::AuthError, "Authorization code not present"
        end

        response = HTTParty.post(
          auth_endpoint,
          headers: headers,
          body: request_access_token_payload
        )

        if response.ok?
          update_auth_token(response)
        else
          refresh_access_token
        end
      end

      def auth_endpoint
        "https://auth.#{ENV['TRUELAYER_BASE_URL']}/connect/token"
      end

      def headers
        { 'Content-Type': 'application/x-www-form-urlencoded' }
      end

      def common_auth_payload
        {
          client_id: ENV['TRUELAYER_CLIENT_ID'],
          client_secret: ENV['TRUELAYER_CLIENT_SECRET']
        }
      end

      def request_access_token_payload
        {
          grant_type: 'authorization_code',
          code: @auth_token.authorization_code,
          redirect_uri: ENV['TRUELAYER_REDIRECT_URL']
        }.merge!(common_auth_payload)
      end

      def refresh_access_token
        response = HTTParty.post(
          auth_endpoint,
          headers: headers,
          body: refresh_access_token_payload
        )

        if response.bad_request?
          raise Finance::Aib::AuthError, "Error while refreshing auth token"
        end

        update_auth_token(response)
      end

      def refresh_access_token_payload
        {
          grant_type: 'refresh_token',
          refresh_token: @auth_token.refresh_token
        }.merge!(common_auth_payload)
      end

      def update_auth_token(response)
        auth_token = AuthToken.token_for(AuthToken::PROVIDER_AIB)

        auth_token.access_token = response['access_token']
        auth_token.expiration_time = Time.now.to_i + response['expires_in'].to_i
        auth_token.refresh_token = response['refresh_token']
        auth_token.save!

        @auth_token = auth_token
      end

      def handle_error(additional_data, error_type)
        case error_type
        when :auth
          handle_auth_error(additional_data)
        when :request
          handle_request_error(additional_data)
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
        Jets.logger.warn "Error in #{self.class}: Non-200 status code received: #{e.code}"
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
