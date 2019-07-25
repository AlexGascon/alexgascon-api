# frozen_string_literal: true

RSpec.describe Health::CreateMealJob do
  describe 'create_meal' do
    let(:event) { File.read('spec/fixtures/sns_events/health/MealEaten.json') }

    subject { described_class.perform_now(:create_meal, event) }

    it 'creates a new meal' do
      expect { subject }.to change { Health::Meal.all.count }.by(1)
    end

    it 'returns the meal' do
      expect(subject).to be_a_kind_of Health::Meal
    end

    it 'sets the meal attributes correctly' do
      expect(subject.carbohydrates_portions).to eq 4
      expect(subject.date).to eq Date.parse('2019-10-30')
      expect(subject.food).to eq 'Food for thought'
      expect(subject.meal_type).to eq 'Almuerzo'
      expect(subject.notes).to eq 'Meal notes'
    end
  end
end