# frozen_string_literal: true

module Finance
  module Aib
    class AuthError < StandardError; end

    class Service
      def initialize
        @auth_error = false
      end

      def get_transactions(from, to = nil)
        to ||= from

        authenticate unless @auth_token

        response = request_transactions(from, to)

        if response.unauthorized?
          authenticate
          response = request_transactions(from, to)
        end

        response['results']
      rescue Finance::Aib::AuthError => e
        Jets.logger.warn "Authentication error: #{e.message}"

        @auth_error = true
        []
      ensure
        publish_auth_error_metric
      end

      private

      def request_transactions(from, to)
        # TrueLayer considers the end of the range to not to be included
        # so to get its movements we need to ask for the transactions up
        # to the following day
        response = HTTParty.get(
          api_endpoint,
          headers: api_headers,
          query: { from: from.strftime('%Y-%m-%d'), to: (to + 1.day).strftime('%Y-%m-%d') }
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

      def publish_auth_error_metric
        auth_error_metric = Metrics::BaseMetric.new
        auth_error_metric.namespace = "#{Metrics::Namespaces::INFRASTRUCTURE}/#{Metrics::Namespaces::FINANCE}/AIB"
        auth_error_metric.metric_name = 'Auth error'
        auth_error_metric.unit = Metrics::Units::COUNT
        auth_error_metric.value = @auth_error ? 1 : 0
        auth_error_metric.timestamp = DateTime.now
        auth_error_metric.dimensions = []

        PublishCloudwatchDataCommand.new(auth_error_metric).execute
      end
    end
  end
end
