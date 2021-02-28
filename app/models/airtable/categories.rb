# frozen_string_literal: true

module Airtable
  module Categories
    BAR_RESTAURANT = 'Bar / Restaurant'
    FUN = 'Ocio'
    SUPERMARKET = 'Supermercado'

    MAPPING = {
      Finance::ExpenseCategories::COCA_COLA => BAR_RESTAURANT,
      Finance::ExpenseCategories::EATING_OUT => BAR_RESTAURANT,
      Finance::ExpenseCategories::FUN => FUN,
      Finance::ExpenseCategories::SUPERMARKET => SUPERMARKET
    }.freeze
  end
end
