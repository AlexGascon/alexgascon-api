# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthService
      def obtain_oauth_token(authorization_code)
        token.authorization_code = authorization_code

        @response = request_auth_token
        token.update_attributes!(auth_token_attributes)
      end

      private

      def request_auth_token
        HTTParty.post(endpoint_url, headers: headers, body: auth_payload)
      end

      def auth_token_attributes
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

      def base_payload
        {
          client_id: ENV['DEXCOM_CLIENT_ID'],
          client_secret: ENV['DEXCOM_CLIENT_SECRET'],
          redirect_uri: ENV['DEXCOM_REDIRECT_URI']
        }
      end

      def auth_payload
        base_payload.merge!(code: token.authorization_code, grant_type: 'authorization_code')
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
