# frozen_string_literal: true

FactoryBot.define do
  factory :bank_transaction, class: Finance::BankTransaction do
    amount_in_cents { 4200 }
    bank            { 'Openbank' }
    datetime        { DateTime.now - 1.day }
    description     { 'Expense on the universe, the meaning of life and everything else' }
    internal_id     { 'BH095' }
  end
end
