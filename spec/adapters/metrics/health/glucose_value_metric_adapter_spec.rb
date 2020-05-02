# frozen_string_literal: true

RSpec.describe Metrics::Health::GlucoseValueMetricAdapter do
  let(:glucose_value) { FactoryBot.build(:glucose_value) }
  let(:metric) { subject.data }

  subject { described_class.new(glucose_value) }

  it 'sets the metric namespace' do
    expect(metric.namespace).to eq 'Health'
  end

  it 'sets the metric name' do
    expect(metric.metric_name).to eq 'Glucose'
  end

  it 'sets the metric value' do
    expect(metric.value).to eq 95
  end

  it 'sets the timestamp' do
    expect(metric.timestamp).to eq glucose_value.timestamp
  end
end
