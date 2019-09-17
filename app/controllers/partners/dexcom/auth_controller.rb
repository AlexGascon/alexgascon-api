# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthController < ::ApplicationController
      def auth_callback
        return head :unauthorized if unauthorized?

        auth_service.obtain_oauth_token(auth_code)

        head :ok
      end

      private

      def auth_code
        @auth_code ||= permitted_params[:authorization_code]
      end

      def auth_service
        @auth_service ||= Partners::Dexcom::AuthService.new
      end

      def unauthorized?
        auth_code.blank?
      end

      def permitted_params
        params.permit(:authorization_code)
      end
    end
  end
end
