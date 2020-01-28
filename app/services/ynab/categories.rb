# frozen_string_literal: true

module Ynab
  module Categories
    COCA_COLA_ID = '2acef0a6-0432-412b-91a4-45d68eb6efc4'
    EATING_OUT_ID = 'f8ba8264-2699-49b4-b233-1fca11788721'
    FUN_ID = 'e84c51bf-3739-4212-b0b0-496839f90d76'
    SUPERMARKET_ID = 'bce9fcf8-7a1f-46b2-af2c-4b998ac4785b'

    UNCATEGORIZED_CATEGORY_ID = 'e172c064-eb5c-4fb2-9bd7-ae5fe9af692f'

    CATEGORY_IDS = {
      Finance::ExpenseCategories::COCA_COLA => COCA_COLA_ID,
      Finance::ExpenseCategories::EATING_OUT => EATING_OUT_ID,
      Finance::ExpenseCategories::FUN => FUN_ID,
      Finance::ExpenseCategories::SUPERMARKET => SUPERMARKET_ID
    }.freeze
  end
end
