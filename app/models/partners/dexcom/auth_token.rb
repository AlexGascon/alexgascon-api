# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthToken
      include Dynamoid::Document

      field :access_token, :string
      field :expiration_time, :number 
      field :refresh_token, :string

      def self.instance
        return new if count.zero?

        first
      end
    end
  end
end
