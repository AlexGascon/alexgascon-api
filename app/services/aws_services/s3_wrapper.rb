# frozen_string_literal: true

module AwsServices
  class S3Wrapper
    attr_reader :client, :bucket, :filename

    ACCESS_POLICY = 'public-read'
    DEFAULT_BUCKET_NAME = 'alexgascon-api-files'
    REGION = 'eu-west-1'

    def initialize(bucket: nil)
      @client = Aws::S3::Client.new
      @bucket = bucket || DEFAULT_BUCKET_NAME
    end

    def store_image(image_body, filename: nil)
      filename ||= default_filename

      client.put_object(
        acl: ACCESS_POLICY,
        bucket: bucket,
        body: image_body,
        key: filename
      )

      file_url(filename)
    end

    def get_file(filename)
      response = client.get_object(
        bucket: bucket,
        key: filename
      )

      response.body.read
    end

    private

    def default_filename(extension: 'png')
      "image-#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension}"
    end

    def file_url(filename)
      "https://#{bucket}.s3-#{REGION}.amazonaws.com/#{filename}"
    end
  end
end
