class CreateMeals < ActiveRecord::Migration[5.2]
  def change
    create_table :meals do |t|
      t.float :carbohydrates_portions
      t.date :date
      t.string :food
      t.integer :meal_type
      t.text :notes

      t.timestamps
    end
  end
end
