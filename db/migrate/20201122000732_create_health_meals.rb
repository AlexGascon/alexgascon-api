class CreateHealthMeals < ActiveRecord::Migration[6.0]
  def change
    create_table :health_meals do |t|
      t.float :carbohydrates_portions
      t.datetime :date
      t.text :food
      t.text :meal_type
      t.text :notes

      t.timestamps
    end
  end
end
