# frozen_string_literal: true

RSpec.describe Health::GetLiveDexcomDataJob do
  let(:redis_env) do
    {
      'REDIS_HOST' => 'localhost',
      'REDIS_PORT' => '6379',
      'REDIS_PASSWORD' => 'pass'
    }
  end

  describe '#run' do
    let(:minutes) { 180 }
    let(:bg_datapoints) { minutes / 5 }

    before do
      bgs = build_list(:dexcom_blood_glucose, bg_datapoints)
      allow(Dexcom::BloodGlucose).to receive(:get_last).with(minutes: minutes).and_return(bgs)

      @command_double = instance_double(PublishCloudwatchDataCommand)
      allow(PublishCloudwatchDataCommand)
        .to receive(:new)
        .with(a_kind_of Health::GlucoseValue)
        .and_return(@command_double)
      allow(@command_double).to receive(:execute)
    end

    around do |example|
      with_modified_env(redis_env) do
        example.run
        Redis.current.flushall
      end
    end

    subject { described_class.perform_now(:run) }

    it 'creates GlucoseValues correctly' do
      expect { subject }.to change { Health::GlucoseValue.count }.by(bg_datapoints)

      example_glucose_value = Health::GlucoseValue.last
      expect(example_glucose_value.value).to eq 142
      expect(example_glucose_value.timestamp).to eq DateTime.new(2020, 6, 10, 21, 43, 14, '+00:00')
    end

    it 'publishes the glucose metrics' do
      # NOTE: If this fails, maybe the method has been called, but not on the double
      # That would mean that PublishCloudwatchDataCommand.new hasn't been called with
      # an instance of Health::GlucoseValue
      expect(@command_double).to receive(:execute).exactly(bg_datapoints).times

      subject
    end

    context 'when a glucose value was recently published' do
      it 'does not publish the glucose metric again' do
        expect(@command_double).to receive(:execute).exactly(bg_datapoints).times
        described_class.perform_now(:run)

        expect(@command_double).not_to receive(:execute)
        described_class.perform_now(:run)
      end
    end

    context 'when Redis is unavailable' do
      before do
        allow(Redis.current).to receive(:get).and_raise(Redis::BaseError)
        allow(Redis.current).to receive(:set).and_raise(Redis::BaseError)

        @redis_metric_command_double = instance_double(PublishCloudwatchDataCommand)
        allow(PublishCloudwatchDataCommand)
          .to receive(:new)
          .with(
            a_kind_of(Metrics::BaseMetric)
            .and fields_with_values(namespace: 'Infrastructure', metric_name: 'Error')
          )
          .and_return(@redis_metric_command_double)
        allow(@redis_metric_command_double).to receive(:execute)
      end

      it 'publishes all values' do
        expect(@command_double).to receive(:execute).exactly(bg_datapoints)

        subject
      end

      it 'publishes the error metric' do
        expect(@redis_metric_command_double).to receive(:execute)

        subject
      end
    end
  end
end
