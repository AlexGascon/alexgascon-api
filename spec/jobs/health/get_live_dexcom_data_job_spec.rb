# frozen_string_literal: true

RSpec.describe Health::GetLiveDexcomDataJob do
  describe '#run' do
    let(:minutes) { 1440 }
    let(:bg_datapoints) { minutes / 5 }

    before do
      bgs = build_list(:dexcom_blood_glucose, bg_datapoints)
      allow(Dexcom::BloodGlucose).to receive(:get_last).with(minutes: minutes).and_return(bgs)

      stub_command(PublishCloudwatchDataCommand)
    end

    subject { described_class.perform_now(:run) }

    it 'creates GlucoseValues correctly' do
      expect { subject }.to change { Health::GlucoseValue.count }.by(bg_datapoints)

      example_glucose_value = Health::GlucoseValue.last
      expect(example_glucose_value.value).to eq 142
      expect(example_glucose_value.timestamp).to eq DateTime.new(2020, 6, 10, 21, 43, 14, '+00:00')
    end

    it 'publishes the glucose metrics' do
      command_double = instance_double(PublishCloudwatchDataCommand)
      allow(PublishCloudwatchDataCommand)
        .to receive(:new)
        .with(a_kind_of Health::GlucoseValue)
        .and_return(command_double)

      # NOTE: If this fails, maybe the method has been called, but not on the double
      # That would mean that PublishCloudwatchDataCommand.new hasn't been called with
      # an instance of Health::GlucoseValue
      expect(command_double).to receive(:execute).exactly(bg_datapoints).times

      subject
    end
  end
end
