# frozen_string_literal: true

RSpec.describe Metrics::ExpenseMetric do
  let(:expense) do
    Finance::Expense.new(
      amount: 12,
      category: Finance::ExpenseCategories::SUPERMARKET,
      notes: 'test injection'
    )
  end

  describe '#new' do
    subject(:metric) { Metrics::ExpenseMetric.new(expense) }

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
  end
end
