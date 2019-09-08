# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthController < ::ApplicationController
      def auth_callback
        render json: { msg: "Works" }, status: :ok
      end

      private

      def auth_code
        @auth_code ||= permitted_params[:authorization_code]
      end

      def permitted_params
        params.permit(:authorization_code)
      end
    end
  end
end
