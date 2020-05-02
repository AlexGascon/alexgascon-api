# frozen_string_literal: true

RSpec.describe GetS3FileCommand do
  let(:bucket_name) { 'MyBucket' }
  let(:file_path) { 'Folder/MyFile.txt' }
  let(:file_content) { 'Content content, lots of content' }

  subject(:command) { described_class.new(bucket_name, file_path) }

  before do
    allow_any_instance_of(AwsServices::S3Wrapper).to receive(:get_file).and_return(file_content)
  end

  describe 'execute' do
    it 'sets the bucket correctly' do
      expect(AwsServices::S3Wrapper)
        .to receive(:new)
        .and_call_original
        .with a_hash_including(bucket: bucket_name)

      command.execute
    end

    it 'gets the correct file' do
      expect_any_instance_of(AwsServices::S3Wrapper)
        .to receive(:get_file).with(file_path)

      command.execute
    end

    it 'returns the file content' do
      expect(command.execute).to eq file_content
    end
  end
end
