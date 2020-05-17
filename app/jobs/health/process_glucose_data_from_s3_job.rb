# frozen_string_literal: true

class Health::ProcessGlucoseDataFromS3Job < ::ApplicationJob
  # Setting a timeout higher than default as there's a lot of processing
  class_timeout 600

  BUCKET_NAME = 'alexgascon-api-files'
  DEXCOM_FILES_PREFIX = 'dexcom/cgm-data'

  s3_event BUCKET_NAME
  def run
    return unless s3_file_path.starts_with? DEXCOM_FILES_PREFIX

    content = get_s3_file
    dexcom_data = parse_cgm_data(content)

    Parallel.each(dexcom_data.entries, in_threads: 4) do |dexcom_glucose_entry|
      begin
        glucose_value = create_glucose_object(dexcom_glucose_entry)
        publish_metric(glucose_value)
      rescue Aws::DynamoDB::Errors::ProvisionedThroughputExceeded => e
        Jets.logger.warn "Error with entry: #{dexcom_glucose_entry}"
        Jets.logger.warn "Error encountered: #{e}"

        retry
      end
    end
  end

  private

  def get_s3_file
    GetS3FileCommand.new(BUCKET_NAME, s3_file_path).execute
  end

  def s3_file_path
    CGI.unescape s3_object['key']
  end

  def parse_cgm_data(content)
    Health::Dexcom::CgmDataParser.new(content).parse
  end

  def create_glucose_object(dexcom_glucose_entry)
    Health::GlucoseValueFactory.from_dexcom_entry(dexcom_glucose_entry)
  end

  def publish_metric(glucose_value)
    PublishCloudwatchDataCommand.new(glucose_value).execute
  end
end
