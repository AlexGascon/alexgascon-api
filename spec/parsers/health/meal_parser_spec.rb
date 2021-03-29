# frozen_string_literal: true

RSpec.describe Health::MealParser do
  let(:parser) { described_class.new(sns_event) }

  describe 'parse' do
    let(:sns_event) { load_json_fixture('aws/sns/health/MealEaten') }

    subject { parser.parse }

    it 'returns a hash with the meal information' do
      expected_meal = { carbohydrates_portions: 4, notes: 'Meal notes', meal_type: 'almuerzo', food: 'Food for thought', date: Date.parse('2019-10-30') }

      expect(subject).to include expected_meal
    end
  end
end
