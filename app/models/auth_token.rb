# frozen_string_literal: true

class InvalidTokenProvider < StandardError; end

class AuthToken
  include Dynamoid::Document

  PROVIDER_AIB = :aib
  PROVIDER_DEXCOM = :dexcom
  PROVIDERS = [PROVIDER_AIB, PROVIDER_DEXCOM].freeze

  field :authorization_code, :string
  field :access_token, :string
  field :expiration_time, :number
  field :refresh_token, :string
  field :provider, :string

  global_secondary_index hash_key: :provider, projected_attributes: :all, name: 'provider_index', read_capacity: 1, write_capacity: 1

  def self.token_for(provider)
    raise InvalidTokenProvider unless PROVIDERS.include? provider

    tokens_for_provider = where(provider: provider)

    tokens_for_provider.first || create(provider: provider)
  end
end
