# frozen_string_literal: true

module Health
  class MealParser < SnsParser
    def parse
      {
        carbohydrates_portions: event[:carbohydrates_portions],
        date: date,
        food: event[:food],
        meal_type: event[:meal_type],
        notes: event[:notes]
      }
    end

    private

    def date
      return unless event[:date]

      Date.parse event[:date]
    end
  end
end
