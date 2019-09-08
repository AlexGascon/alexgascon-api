# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthService
      def initialize(authorization_code)
        @authorization_code = authorization_code
      end

      def obtain_oauth_token
      end
    end
  end
end