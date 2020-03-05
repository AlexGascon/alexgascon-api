# frozen_string_literal: true

RSpec.describe AwsServices::S3Wrapper do
  let(:s3_service) { instance_double(Aws::S3::Client) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return s3_service
    allow(s3_service).to receive(:put_object)
  end

  subject { described_class.new }

  describe 'store_image' do
    it 'stores the image' do
      expect(s3_service).to receive(:put_object)

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
      let(:bucket_name) { 'my-bucket' }

      subject { described_class.new(bucket: bucket_name) }

      it 'stores the image in that bucket' do
        expect(s3_service)
          .to receive(:put_object)
          .with hash_including(bucket: bucket_name)

        subject.store_image('imagebody')
      end
    end
  end
end
