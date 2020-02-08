# frozen_string_literal: true

RSpec.describe AwsServices::CloudwatchWrapper do
  let(:metrics_service) { instance_double(Aws::CloudWatch::Client) }

  before do
    allow(Aws::CloudWatch::Client).to receive(:new).and_return metrics_service
    allow(metrics_service).to receive(:put_metric_data)
  end

  describe '#publish_expense' do
    before { allow(metrics_service).to receive(:put_metric_data) }

    it 'publishes the expense in CloudWatch' do
      expense = Finance::Expense.new(amount: 42, category: 'eating out', notes: 'test expense note')
      expected_metric_data = {
        namespace: 'Finance',
        metric_data: [Metrics::ExpenseMetric.new(expense)]
      }

      expect(metrics_service).to receive(:put_metric_data).with(expected_metric_data)
      AwsServices::CloudwatchWrapper.new.publish_expense(expense)
    end
  end
end
