# frozen_string_literal: true

module Airtable
  module Categories
    BAR_RESTAURANT = 'Bar / Restaurant'
    FUN = 'Ocio'
    INVESTMENTS = 'Inversiones'
    SUBSCRIPTIONS = 'Subscriptions'
    SUPERMARKET = 'Supermercado'

    UNDEFINED = 'Sin clasificar'

    MAPPING = {
      Finance::ExpenseCategories::COCA_COLA => BAR_RESTAURANT,
      Finance::ExpenseCategories::EATING_OUT => BAR_RESTAURANT,
      Finance::ExpenseCategories::FUN => FUN,
      Finance::ExpenseCategories::INVESTMENT => INVESTMENTS,
      Finance::ExpenseCategories::SUBSCRIPTION => SUBSCRIPTIONS,
      Finance::ExpenseCategories::SUPERMARKET => SUPERMARKET
    }.freeze
  end
end
