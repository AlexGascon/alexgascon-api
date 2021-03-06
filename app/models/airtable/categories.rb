# frozen_string_literal: true

module Airtable
  module Categories
    BAR_RESTAURANT = 'Bar / Restaurant'
    FUN = 'Ocio'
    SUBSCRIPTIONS = 'Subscriptions'
    SUPERMARKET = 'Supermercado'

    MAPPING = {
      Finance::ExpenseCategories::COCA_COLA => BAR_RESTAURANT,
      Finance::ExpenseCategories::EATING_OUT => BAR_RESTAURANT,
      Finance::ExpenseCategories::FUN => FUN,
      Finance::ExpenseCategories::SUBSCRIPTION => SUBSCRIPTIONS,
      Finance::ExpenseCategories::SUPERMARKET => SUPERMARKET
    }.freeze
  end
end
