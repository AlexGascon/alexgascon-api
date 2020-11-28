# frozen_string_literal: true

# == Schema Information
#
# Table name: health_meals
#
#  id                     :bigint           not null, primary key
#  carbohydrates_portions :float
#  date                   :datetime
#  food                   :text
#  meal_type              :text
#  notes                  :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
module Health
  class Meal < ::ApplicationRecord
  end
end
