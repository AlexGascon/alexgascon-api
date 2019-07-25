# frozen_string_literal: true

module Health
  class Meal
    include Dynamoid::Document

    field :carbohydrates_portions, :number
    field :date, :date
    field :food, :string
    field :meal_type, :string
    field :notes, :string

    validates_presence_of :food
    validates_presence_of :meal_type
  end
end