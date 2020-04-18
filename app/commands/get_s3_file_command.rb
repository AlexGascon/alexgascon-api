# frozen_string_literal: true

class GetS3FileCommand
  attr_reader :bucket_name, :file_path

  def initialize(bucket_name, file_path)
    @bucket_name = bucket_name
    @file_path = file_path
  end

  def execute
    s3.get_file(file_path)
  end

  private

  def s3
    @s3 ||= AwsServices::S3Wrapper.new(bucket: bucket_name)
  end
end
