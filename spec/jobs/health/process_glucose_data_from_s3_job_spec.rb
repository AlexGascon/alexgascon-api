# frozen_string_literal: true

RSpec.describe Health::ProcessGlucoseDataFromS3Job do
  subject { described_class.perform_now(:run, event) }

  describe 'run' do
    let(:event) { load_json_fixture 'aws/s3/dexcom_file_event' }
    let(:cgm_fixture) { File.read('spec/fixtures/dexcom/cgm_data.csv') }

    before do
      stub_command(GetS3FileCommand)
      allow_any_instance_of(GetS3FileCommand).to receive(:execute).and_return(cgm_fixture)
      stub_command(PublishCloudwatchDataCommand)
    end

    it 'creates the glucose values' do
      expect { subject }.to change { Health::GlucoseValue.count }.by(16)
    end

    it 'publishes the glucose metrics' do
      command_double = instance_double(PublishCloudwatchDataCommand)
      allow(PublishCloudwatchDataCommand).to receive(:new).and_return(command_double)

      expect(command_double).to receive(:execute).exactly(16).times

      subject
    end

    context 'when the file does not contain Dexcom data' do
      let(:event) { load_json_fixture 'aws/s3/new_file_event' }

      it 'skips the process' do
        expect_any_instance_of(GetS3FileCommand).not_to receive(:execute)
        expect_any_instance_of(PublishCloudwatchDataCommand).not_to receive(:execute)

        subject
      end
    end
  end
end
