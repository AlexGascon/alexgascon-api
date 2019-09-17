# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthService
      attr_reader :authorization_code

      def initialize(authorization_code)
        @authorization_code = authorization_code
      end

      def obtain_oauth_token
        @response = request_auth_token
        token_attributes = extract_auth_token

        token.update_attributes!(token_attributes)
      end

      private

      def request_auth_token
        HTTParty.post(endpoint_url, headers: headers, body: body)
      end

      def extract_auth_token
        {
          access_token: response_body['access_token'],
          expiration_time: Time.now.to_i + response_body['expires_in'].to_i,
          refresh_token: response_body['refresh_token']
        }
      end

      def endpoint_url
        "#{ENV['DEXCOM_URL']}/v2/oauth2/token"
      end

      def headers
        { 'Content-Type': 'application/x-www-form-urlencoded' }
      end

      def body
        {
          client_id: ENV['DEXCOM_CLIENT_ID'],
          client_secret: ENV['DEXCOM_CLIENT_SECRET'],
          code: authorization_code,
          grant_type: 'authorization_code',
          redirect_uri: ENV['DEXCOM_REDIRECT_URI']
        }
      end

      def response_body
        @response_body ||= JSON.parse(@response.body)
      end

      def token
        @token ||= Partners::Dexcom::AuthToken.instance
      end
    end
  end
end
