# frozen_string_literal: true

FactoryBot.define do
  factory :aib_token, class: AuthToken do
    access_token        { 'defaultFactoryAccessToken' }
    authorization_code  { '122345678' }
    expiration_time     { '14974924021' }
    refresh_token       { 'defaultFactoryRefreshToken' }
    provider            { :aib }
  end
end
