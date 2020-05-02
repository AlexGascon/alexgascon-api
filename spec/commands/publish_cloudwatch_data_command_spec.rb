# frozen_string_literal: true

RSpec.describe PublishCloudwatchDataCommand do
  let(:publishable) { build(:glucose_value) }

  before do
    allow_any_instance_of(AwsServices::CloudwatchWrapper).to receive(:publish)
  end

  describe 'execute' do
    it 'publishes the received object' do
      expect_any_instance_of(AwsServices::CloudwatchWrapper)
        .to receive(:publish)
        .with(publishable)

      described_class.new(publishable).execute
    end
  end
end
