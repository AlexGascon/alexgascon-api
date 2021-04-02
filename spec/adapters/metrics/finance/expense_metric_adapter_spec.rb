# frozen_string_literal: true

RSpec.describe Metrics::Finance::ExpenseMetricAdapter do
  let(:expense) do
    Finance::Expense.new(
      amount: 12,
      category: Finance::ExpenseCategories::SUPERMARKET,
      notes: 'test injection'
    )
  end

  describe '#new' do
    subject(:metric) { described_class.new(expense) }

    it 'sets the metric name' do
      expect(metric.metric_name).to eq 'Money spent'
    end

    it 'sets the metric value' do
      expect(metric.value).to eq 12
    end

    it 'sets the timestamp' do
      expect(metric.timestamp).to eq expense.created_at
    end

    it 'sets only one dimension' do
      expect(metric.dimensions.size).to eq 1
    end

    it 'sets the "Category" dimension' do
      dimension = metric.dimensions.first
      expect(dimension[:name]).to eq 'Category'
      expect(dimension[:value]).to eq 'Supermarket'
    end

    context 'categories with direct mapping' do
      CATEGORIES_WITH_DIRECT_MAPPING = {
        Finance::ExpenseCategories::FUN => 'Fun',
        Finance::ExpenseCategories::SUPERMARKET => 'Supermarket'
      }

      CATEGORIES_WITH_DIRECT_MAPPING.each_pair do |expense_category, dimension|
        it "#{expense_category} is mapped correctly" do
          expense = build(:unclassified_expense, category: expense_category)
          metric = described_class.new(expense)

          expect(metric.dimensions.first[:name]).to eq 'Category'
          expect(metric.dimensions.first[:value]).to eq dimension
        end
      end
    end

    context 'categories without direct mapping' do
      let(:expense) { create(:netflix_expense) }

      it 'are mapped automatically' do
        dimension = metric.dimensions.first

        expect(dimension[:name]).to eq 'Category'
        expect(dimension[:value]).to eq 'Subscription'
      end
    end
  end
end
