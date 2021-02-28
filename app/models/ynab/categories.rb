# frozen_string_literal: true

module Ynab
  module Categories
    COCA_COLA_ID = '05dd5f21-21b7-4f4c-8682-7d41f4b37d71'
    EATING_OUT_ID = 'c494b8b4-a82c-4ba7-941e-b3ee811206ab'
    FUN_ID = 'c494b8b4-a82c-4ba7-941e-b3ee811206ab'
    SUPERMARKET_ID = '2b65b6fd-25f0-42cc-9664-1c4cc61812a7'

    UNCATEGORIZED_CATEGORY_ID = 'e172c064-eb5c-4fb2-9bd7-ae5fe9af692f'

    CATEGORY_IDS = {
      Finance::ExpenseCategories::COCA_COLA => COCA_COLA_ID,
      Finance::ExpenseCategories::EATING_OUT => EATING_OUT_ID,
      Finance::ExpenseCategories::FUN => FUN_ID,
      Finance::ExpenseCategories::SUPERMARKET => SUPERMARKET_ID
    }.freeze
  end
end
