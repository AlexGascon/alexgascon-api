# frozen_string_literal: true

module Finance
  class PlaidClientFactory
    PLAID_API_VERSION = '2020-09-14'

    def self.build
      configuration = Plaid::Configuration.new
      configuration.server_index = Plaid::Configuration::Environment['development']
      configuration.api_key['PLAID-CLIENT-ID'] = ENV['PLAID_CLIENT_ID']
      configuration.api_key['PLAID-SECRET'] = ENV['PLAID_SECRET']
      configuration.api_key['Plaid-Version'] = PLAID_API_VERSION

      api_client = Plaid::ApiClient.new(configuration)

      Plaid::PlaidApi.new(api_client)
    end
  end
end
