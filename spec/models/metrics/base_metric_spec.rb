# frozen_string_literal: true

RSpec.describe Metrics::BaseMetric do
  let(:metric) do
    described_class.new(
      metric_name: 'test', value: 1, timestamp: Time.now,
      dimensions: [{ name: 'Dim1', value: 'Val1' }, { name: 'Dim2', value: 'Val2' }]
    )
  end

  describe '#==' do
    let(:metric2) { metric.dup }

    it 'compares the metric name' do
      expect(metric2).to eq metric

      metric2.metric_name = 'other'
      expect(metric2).not_to eq metric
    end

    it 'compares the metric value' do
      expect(metric2).to eq metric

      metric2.value = 'other'
      expect(metric2).not_to eq metric
    end

    it 'compares the metric timestamp' do
      expect(metric2).to eq metric

      metric2.timestamp = Time.now + 1.minute
      expect(metric2).not_to eq metric
    end

    context 'compares dimensions' do
      before { metric2.dimensions = metric.dimensions.map(&:clone) }

      it 'returns true if their names and values match' do
        expect(metric2).to eq(metric)
      end

      it 'returns false if there are extra dimensions' do
        metric2.dimensions << { name: 'Dim3', value: 'Val3' }

        expect(metric2).not_to eq metric
      end

      it 'returns false if the dimension names do not match' do
        metric2.dimensions.first[:name] = 'OtherDim'

        expect(metric2).not_to eq metric
      end

      it 'returns false if the dimension values do not match' do
        metric2.dimensions.first[:value] = 'OtherValue'

        expect(metric2).not_to eq metric
      end
    end
  end

  describe '#contains_dimension?' do
    it 'returns true if the dimension name and value match' do
      dimension = { name: 'Dim2', value: 'Val2' }

      expect(metric.contains_dimension?(dimension)).to be_truthy
    end

    it 'returns false if there are no dimensions with that name' do
      dimension = { name: 'FakeDim', value: 'Value' }

      expect(metric.contains_dimension?(dimension)).to be_falsey
    end

    it 'returns false if the dimension value does not match' do
      dimension = { name: 'Dim2', value: 'FakeValue' }

      expect(metric.contains_dimension?(dimension)).to be_falsey
    end
  end
end
