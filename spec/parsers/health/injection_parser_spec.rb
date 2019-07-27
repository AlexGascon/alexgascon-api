# frozen_string_literal: true

RSpec.describe Health::InjectionParser do
  let(:parser) { described_class.new(sns_event) }

  describe 'parse' do
    let(:sns_event) { JSON.parse(File.read('spec/fixtures/sns_events/health/InsulinInjected.json')) }

    subject { parser.parse }

    it 'returns a hash with the injection information' do
      expected_injection = { units: 15, notes: 'Injection testing notes', injection_type: 'basal' }

      expect(subject).to include expected_injection
    end
  end
end
