# frozen_string_literal: true

module Partners
  module Dexcom
    class AuthToken
      include Dynamoid::Document

      field :account_id, :string
      field :access_token, :string
      field :expiration_time, :number 
      field :refresh_token, :string
      
      validates_presence_of :account_id
      validates_presence_of :access_token
      validates_presence_of :refresh_token
    end
  end
end
