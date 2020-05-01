# frozen_string_literal: true

RSpec.describe Health::CreateInjectionJob do
  describe 'create_injection' do
    let(:event) { load_json_fixture('sns_events/health/InsulinInjected') }
    let(:metrics_service) { instance_double(AwsServices::CloudwatchWrapper) }

    before do
      allow(AwsServices::CloudwatchWrapper).to receive(:new).and_return metrics_service
      allow(metrics_service).to receive(:publish)
    end

    subject { described_class.perform_now(:create_injection, event) }

    it 'creates a new injection' do
      expect { subject }.to change { Health::Injection.all.count }.by(1)
    end

    it 'returns the injection' do
      expect(subject).to be_a_kind_of Health::Injection
    end

    it 'sets the injection attributes correctly' do
      expect(subject.injection_type).to eq 'basal'
      expect(subject.notes).to eq 'Injection testing notes'
      expect(subject.units).to eq 15
    end

    it 'publishes the injection information to CloudWatch' do
      expect(metrics_service).to receive(:publish).with an_instance_of(Health::Injection)

      subject
    end
  end
end
