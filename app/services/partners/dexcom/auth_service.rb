# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthService
      attr_reader :authorization_code

      def initialize(authorization_code)
        @authorization_code = authorization_code
      end

      def obtain_oauth_token
        HTTParty.post(
          endpoint_url,
          headers: headers,
          body: body
        )
      end

      private

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
    end
  end
end
