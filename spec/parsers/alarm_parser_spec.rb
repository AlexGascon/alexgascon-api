# frozen_string_literal: true

RSpec.describe AlarmParser do
  describe 'parse' do
    let(:event) { load_json_fixture('sns_events/cloudwatch_alarm') }
    let(:parser) { described_class.new(event) }

    subject(:alarm) { parser.parse }

    it 'sets the alarm name' do
      expect(alarm.name).to eq 'Example alarm name'
    end

    it 'sets the alarm description' do
      expect(alarm.description).to eq 'Example alarm description.'
    end

    it 'sets the alarm state' do
      expect(alarm.alarm?).to be true
    end

    it 'includes the reason for the last alarm transition' do
      expected_reason = 'Threshold Crossed: 1 datapoint (10.0) was greater than or equal to the threshold (1.0).'
      expect(alarm.reason).to eq expected_reason
    end
  end
end
