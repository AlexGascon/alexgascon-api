# frozen_string_literal: true

FactoryBot.define do
  factory :plaid_account, class: Plaid::AccountBase do
    account_id   { 'm7utN1reMvMx7KndcdZtJqm1CLTmDgqkQNM9A' }
    balances     { build_list(:plaid_account_balance, 1) }
    mask         { '1234' }
    name         { 'CURRENT-1234' }
    subtype      { 'checking' }
    type         { 'depository' }
  end

  factory :plaid_account_balance, class: Plaid::AccountBalance do
    available         { 12_345.67 }
    current           { 12_346.88 }
    iso_currency_code { 'EUR' }
  end

  factory :plaid_item, class: Plaid::Item do
    available_products      { ['balance'] }
    billed_products         { %w[auth transactions] }
    institution_id          { 'ins_123456' }
    item_id                 { 'DPBDHk12yCZPLRGY4WO0LiDX08huFsnuCTkUE' }
    update_type             { 'background' }
    webhook                 { 'example.com/webhooks'}
    consent_expiration_time { '2021-08-23T18:53:12Z' }

    trait :with_expired_consent do
      consent_expiration_time { '2000-01-01T00:00:00Z' }
    end
  end

  factory :plaid_transaction, class: Plaid::Transaction do
    account_id              { 'm7utN1reMvMx7KndcdZtJqm1CLTmDgqkQNM9A' }
    amount                  { 11.39 }
    category                { ['Food and Drink', 'Restaurants'] }
    category_id             { '13005000' }
    date                    { '2021-06-11' }
    iso_currency_code       { 'EUR' }
    location                { association :plaid_location }
    merchant_name           { 'Deliveroo' }
    name                    { 'DELIVEROO' }
    payment_channel         { 'in store' }
    payment_meta            { association :plaid_payment_meta }
    pending                 { false }
    pending_transaction_id  { 'kk3t7qLhjQGfbZZma4WFPLldcfEexKGAE1lqy' }
    transaction_id          { 'W00Vi6WZnIL0J4I0ToP2uTjvb3GgCvjKmX4c3' }
    transaction_type        { 'place' }

    trait :pending do
      pending { true }
    end
  end

  factory :plaid_location, class: Plaid::Location do
    address       { 'Fake street, 123' }
    city          { 'Springfield' }
    country       { 'Fakeland' }
    lat           { 12.34 }
    lon           { -65.42 }
    postal_code   { '23118' }
    region        { 'Co. Fakeland' }
    store_number  { 55 }
  end

  factory :plaid_payment_meta, class: Plaid::PaymentMeta do
  end

  factory :plaid_transactions_get_response, class: Plaid::TransactionsGetResponse do
    request_id         { 'SmOtM4iZvnZCCNdllQjnFlGXn3u0jkXWkmkTe' }
    accounts           { build_list(:plaid_account, 1) }
    item               { association(:plaid_item) }
    total_transactions { 1 }
    transactions       { build_list(:plaid_transaction, 1) }

    trait :with_pending_transactions do
      after(:build) do |response|
        response.transactions = response.transactions + build_list(:plaid_transaction, 1, :pending)
        response.total_transactions = 2
      end
    end

    trait :with_expired_consent do
      item { association(:plaid_item, :with_expired_consent) }
      transactions { [] }
    end
  end
end
