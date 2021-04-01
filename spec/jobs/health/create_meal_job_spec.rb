# frozen_string_literal: true

RSpec.describe Health::CreateMealJob do
  describe 'create_meal' do
    let(:event) { load_json_fixture('aws/sns/health/MealEaten') }

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
      expect(subject.meal_type).to eq 'almuerzo'
      expect(subject.notes).to eq 'Meal notes'
    end

    context 'when the event does not have any date' do
      let(:event) { load_json_fixture('aws/sns/health/MealEaten-no_date') }

      it 'creates a new meal' do
        expect { subject }.to change { Health::Meal.all.count }.by(1)
      end

      it 'sets the date to nil' do
        expect(subject.date).to be_nil
      end
    end
  end
end
