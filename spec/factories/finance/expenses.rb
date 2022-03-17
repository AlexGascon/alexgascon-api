# frozen_string_literal: true

FactoryBot.define do
  factory :unclassified_expense, class: Finance::Expense do
    amount      { 42.42 }
    category    { 'undefined' }
    notes       { 'Random expense that doesnt make sense' }
  end

  factory :netflix_expense, class: Finance::Expense do
    amount      { 11.99 }
    category    { 'subscription' }
    notes       { 'Compra en paypal *netflix, con la tarjeta xxxxxxx'}
  end

  factory :spotify_expense, class: Finance::Expense do
    amount      { 4.99 }
    category    { 'subscription' }
    notes       { 'Compra en paypal *spotify, con la tarjeta xxxxxxx'}
  end

  factory :pepephone_expense, class: Finance::Expense do
    amount      { 11.9 }
    category    { 'subscription' }
    notes       { 'PEPE MOBILE S.L.U.' }
  end

  factory :deliveroo_subscription, class: Finance::Expense do
    amount      { 10.99 }
    category    { 'subscription' }
    notes       { 'VDP-DELIVEROO PLUS' }
  end

  factory :deliveroo_expense, class: Finance::Expense do
    amount      { '15.42' }
    category    { 'eating out' }
    notes       { 'VDP-DELIVEROO' }
  end

  factory :tesco_expense, class: Finance::Expense do
    amount      { '15.42' }
    category    { 'supermercado' }
    notes       { 'VDC-TESCO STORES 6' }
  end

  factory :mercadona_expense, class: Finance::Expense do
    amount      { '39.87' }
    category    { 'supermercado' }
    notes       { 'MERCADONA TAVE' }
  end

  factory :dynamodb_event_expense, class: Finance::Expense do
    amount      { '4.99' }
    category    { 'subscription' }
    notes       { 'COMPRA EN PAYPAL *SPOTIFY, CON LA TARJETA : XXXXXXXXXXXX4205 EL 2021-03-22' }
    id          { '05a860a8-0174-4a5a-8a15-deea3ac4b2ba' }
  end
end
