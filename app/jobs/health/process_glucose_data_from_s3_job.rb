# frozen_string_literal: true

class Health::ProcessGlucoseDataFromS3Job < ::ApplicationJob
  BUCKET_NAME = 'alexgascon-api-files'
  DEXCOM_FILES_PREFIX = 'dexcom/cgm-data'

  s3_event BUCKET_NAME
  def run
    return unless s3_file_path.starts_with? DEXCOM_FILES_PREFIX

    content = get_s3_file
    dexcom_data = parse_cgm_data(content)

    dexcom_data.entries.each do |dexcom_glucose_entry|
      glucose_value = create_glucose_object(dexcom_glucose_entry)
      publish_metric(glucose_value)
    end
  end

  private

  def get_s3_file
    GetS3FileCommand.new(BUCKET_NAME, s3_file_path).execute
  end

  def s3_file_path
    s3_object['key']
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
