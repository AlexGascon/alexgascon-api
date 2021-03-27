# frozen_string_literal: true

FactoryBot.define do
  factory :bank_transaction, class: Finance::BankTransaction do
    amount_in_cents { 4200 }
    bank            { 'Openbank' }
    datetime        { DateTime.now - 1.day }
    description     { 'Expense on the universe, the meaning of life and everything else' }
    internal_id     { 'BH095' }
  end

  factory :unclassified_bank_transaction, class: Finance::BankTransaction do
    amount_in_cents   { 4242 }
    bank              { 'Openbank' }
    datetime          { DateTime.now - 1.day }
    description       { 'Random expense that doesnt make sense' }
    internal_id       { 'HRTAU' }
  end

  factory :netflix_bank_transaction, class: Finance::BankTransaction do
    amount_in_cents   { 1199 }
    bank              { 'AIB' }
    datetime          { DateTime.now - 1.day }
    description       { 'Compra en paypal *netflix, con la tarjeta xxxxxxx' }
    internal_id       { 'BH095' }
  end

  factory :spotify_bank_transaction, class: Finance::BankTransaction do
    amount_in_cents   { 999 }
    bank              { 'AIB' }
    datetime          { DateTime.now - 1.day }
    description       { 'Compra en paypal *spotify, con la tarjeta xxxxxxx' }
    internal_id       { 'BH095' }
  end

  factory :pepephone_bank_transaction, class: Finance::BankTransaction do
    amount_in_cents   { 1190 }
    bank              { 'AIB' }
    datetime          { DateTime.now - 1.day }
    description       { 'PEPEMOBILE S.L.'}
    internal_id       { 'BH095' }
  end

  factory :deliveroo_subscription_bank_transaction, class: Finance::BankTransaction do
    amount_in_cents   { 1099 }
    bank              { 'AIB' }
    datetime          { DateTime.now - 1.day }
    description       { 'VDP-DELIVEROO PLUS' }
    internal_id       { 'BH095' }
  end

  factory :deliveroo_expense_bank_transaction, class: Finance::BankTransaction do
    amount_in_cents   { 1499 }
    bank              { 'AIB' }
    datetime          { DateTime.now - 1.day }
    description       { 'VDP-DELIVEROO.IE' }
    internal_id       { 'BH095' }
  end
end
