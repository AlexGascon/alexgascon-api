# frozen_string_literal: true

RSpec.describe Health::GetLiveGlucoseDataJob do
  describe '#run' do
    before do
      bg = build(:dexcom_blood_glucose)
      allow(Dexcom::BloodGlucose).to receive(:last).and_return(bg)
    end

    subject { described_class.perform_now(:run) }

    it 'creates a GlucoseValue' do
      expect { subject }.to change { Health::GlucoseValue.count }.by(1)
    end
    
    it 'fills the data correctly' do
      glucose_value = subject
    end
  end
end