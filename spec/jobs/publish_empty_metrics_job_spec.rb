# frozen_string_literal: true

RSpec.describe PublishEmptyMetricsJob do
  let(:mock_cw) { instance_double(AwsServices::CloudwatchWrapper) }

  before do
    allow(AwsServices::CloudwatchWrapper).to receive(:new).and_return(mock_cw)
    allow(mock_cw).to receive(:publish_expense)
    allow(mock_cw).to receive(:publish_injection)
  end

  RSpec.shared_examples 'empty injection metrics' do |type|
    it "publishes an empty #{type} injection" do
      empty_injection = Health::Injection.new(injection_type: type, units: 0)
      expect(mock_cw).to receive(:publish_injection).with(empty_injection)

      subject
    end
  end

  describe '#publish' do
    subject { described_class.perform_now(:publish) }

    context 'injections' do
      INJECTION_TYPES = ['basal', 'bolus']

      INJECTION_TYPES.each do |injection_type|
        include_examples 'empty injection metrics', injection_type
      end
    end
  end
end
