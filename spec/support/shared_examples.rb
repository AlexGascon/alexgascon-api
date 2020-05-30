RSpec.shared_examples 'retry metric' do |retries|
  let(:expected_retries) { retries }

  it 'publishes a metric with the retries' do
    expect(PublishCloudwatchDataCommand).to receive(:new).with(retries_metric)

    subject
  end
end
