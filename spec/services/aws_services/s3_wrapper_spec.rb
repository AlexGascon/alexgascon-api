# frozen_string_literal: true

RSpec.describe AwsServices::S3Wrapper do
  let(:s3_service) { instance_double(Aws::S3::Client) }
  let(:default_bucket_name) { 'alexgascon-api-files' }
  let(:custom_bucket_name) { 'my-bucket' }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return s3_service
  end

  subject { described_class.new }

  describe 'store_image' do
    before { allow(s3_service).to receive(:put_object) }

    it 'stores the image' do
      expect(s3_service).to receive(:put_object)

      subject.store_image('imagebody')
    end

    it 'uses a default bucket if you do not specify any' do
      expect(s3_service).to receive(:put_object).with a_hash_including(bucket: default_bucket_name)

      subject.store_image('imagebody')
    end

    it 'returns the image URL' do
      expected_url = 'https://alexgascon-api-files.s3-eu-west-1.amazonaws.com/myfile.png'

      url = subject.store_image('imagebody', filename: 'myfile.png')

      expect(expected_url).to eq url
    end

    it 'sets the image as publicly readable' do
      expect(s3_service)
        .to receive(:put_object)
        .with hash_including(acl: 'public-read')

      subject.store_image('imagebody')
    end

    it 'lets you specify the filename' do
      filename = 'my-custom-filename.jpg'

      expect(s3_service)
        .to receive(:put_object)
        .with hash_including(key: 'my-custom-filename.jpg')

      subject.store_image('imagebody', filename: filename)
    end

    context 'when the bucket name is passed to the constructor' do
      subject(:client_with_custom_bucket) { described_class.new(bucket: custom_bucket_name) }

      it 'stores the image in that bucket' do
        expect(s3_service)
          .to receive(:put_object)
          .with hash_including(bucket: custom_bucket_name)

        client_with_custom_bucket.store_image('imagebody')
      end
    end
  end

  describe 'get_file' do
    let(:filename) { 'spec/fixtures/file.txt' }
    let(:get_object_response) { Aws::S3::Types::GetObjectOutput.new(body: File.new(filename)) }

    before { allow(s3_service).to receive(:get_object).and_return(get_object_response) }

    it 'retrieves the file from S3' do
      expect(s3_service).to receive(:get_object)
        .with a_hash_including(key: filename, bucket: default_bucket_name)

      subject.get_file(filename)
    end

    it 'returns the content of the file' do
      expected_content = 'Hey, this is some content'

      expect(subject.get_file(filename)).to eq expected_content
    end

    context 'when the bucket name is passed to the constructor' do
      subject(:client_with_custom_bucket) { described_class.new(bucket: custom_bucket_name) }

      it 'retrieves the file from that bucket' do
        expect(s3_service).to receive(:get_object)
          .with a_hash_including(key: filename, bucket: custom_bucket_name)

        client_with_custom_bucket.get_file(filename)
      end
    end
  end
end
