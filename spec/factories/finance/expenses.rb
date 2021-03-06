# frozen_string_literal: true

FactoryBot.define do
  factory :netflix_expense, class: Finance::Expense do
    amount      { 11.99 }
    category    { 'subscription' }
    notes       { 'Compra en paypal *netflix, con la tarjeta xxxxxxx'}
  end

  factory :spotify_expense, class: Finance::Expense do
    amount      { 9.99 }
    category    { 'subscription' }
    notes       { 'Compra en paypal *spotify, con la tarjeta xxxxxxx'}
  end

  factory :pepephone_expense, class: Finance::Expense do
    amount      { 11.9 }
    category    { 'subscription' }
    notes       { 'PEPEMOBILE S.L.' }
  end

  factory :deliveroo_subscription, class: Finance::Expense do
    amount      { 10.99 }
    category    { 'subscription' }
    notes       { 'VDP-DELIVEROO PLUS' }
  end

  factory :deliveroo_expense, class: Finance::Expense do
    amount      { '15.42' }
    category    { 'eating out' }
    notes       { 'VDP-DELIVEROO.IE' }
  end
end
