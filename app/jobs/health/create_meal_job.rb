# frozen_string_literal: true

module Health
  class CreateMealJob < ApplicationJob
    sns_event 'MealEaten'

    def create_meal
      meal_information = Health::MealParser.new(event).parse
      Jets.logger.debug "Parsed meal #{meal_information}"

      meal = Meal.create!(
        carbohydrates_portions: meal_information[:carbohydrates_portions],
        date: meal_information[:date],
        food: meal_information[:food],
        meal_type: meal_information[:meal_type],
        notes: meal_information[:notes]
      )
      Jets.logger.debug "Created meal #{meal}"

      meal
    end
  end
end
