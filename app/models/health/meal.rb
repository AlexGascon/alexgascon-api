# frozen_string_literal: true

module Health
  class Meal < ::ApplicationRecord
    enum meal_type: %i[breakfast almuerzo lunch merienda dinner other]
  end
end