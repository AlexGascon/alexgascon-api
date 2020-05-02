# frozen_string_literal: true

RSpec.describe Metrics::Health::InjectionMetricAdapter do
  let(:injection) { Health::Injection.new(units: 22, injection_type: Health::Injection::TYPE_BASAL, notes: 'test injection') }

  describe '#new' do
    let(:metric) { subject.data }
    subject { described_class.new(injection) }

    it 'sets the metric namespace' do
      expect(subject.namespace).to eq 'Health'
    end

    it 'sets the metric name' do
      expect(metric.metric_name).to eq 'Insulin'
    end

    it 'sets the metric value' do
      expect(metric.value).to eq 22
    end

    it 'sets the units' do
      expect(metric.unit).to eq 'Count'
    end

    it 'sets the timestamp' do
      expect(metric.timestamp).to eq injection.created_at
    end

    it 'sets only one dimension' do
      expect(metric.dimensions.size).to eq 1
    end

    it 'sets the "Type" dimension' do
      dimension = metric.dimensions.first
      expect(dimension[:name]).to eq 'Type'
      expect(dimension[:value]).to eq 'Basal'
    end
  end
end
