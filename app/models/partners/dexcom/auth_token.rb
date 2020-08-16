# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthToken
      include Dynamoid::Document

      field :authorization_code, :string
      field :access_token, :string
      field :expiration_time, :number
      field :refresh_token, :string

      def self.instance
        Jets.logger.warn 'This class is deprecated, use AuthToken instead'

        create if first.nil?

        first
      end
    end
  end
end
