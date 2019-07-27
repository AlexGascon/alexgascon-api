# frozen_string_literal: true

RSpec.describe Health::CreateInjectionJob do
  describe 'create_injection' do
    let(:event) { JSON.parse(File.read('spec/fixtures/sns_events/health/InsulinInjected.json')) }

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
  end
end
