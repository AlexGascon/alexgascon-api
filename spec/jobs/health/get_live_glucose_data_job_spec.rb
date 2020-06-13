# frozen_string_literal: true

RSpec.describe Health::GetLiveGlucoseDataJob do
  describe '#run' do
    before do
      bg = build(:dexcom_blood_glucose)
      allow(Dexcom::BloodGlucose).to receive(:last).and_return(bg)

      stub_command(PublishCloudwatchDataCommand)
    end

    subject { described_class.perform_now(:run) }

    it 'creates a GlucoseValue' do
      expect { subject }.to change { Health::GlucoseValue.count }.by(1)
    end
    
    it 'fills the data correctly' do
      glucose_value = subject
    end

    it 'publishes the glucose metrics' do
      command_double = instance_double(PublishCloudwatchDataCommand)
      allow(PublishCloudwatchDataCommand).to receive(:new).and_return(command_double)

      expect(command_double).to receive(:execute).exactly(1).times

      subject
    end
  end
end