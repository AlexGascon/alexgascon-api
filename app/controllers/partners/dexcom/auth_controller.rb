# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthController < ::ApplicationController
      def auth_callback
        return render json: { error: "" }, status: :unauthorized if unauthorized?

        render json: { msg: "Works" }, status: :ok
      end

      private

      def auth_code
        @auth_code ||= permitted_params[:authorization_code]
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
