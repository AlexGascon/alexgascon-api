# frozen_string_literal: true

class Health::Dexcom::CgmDataParser
  attr_reader :content

  GLUCOSE = 'Glucose Value (mg/dL)'
  SOURCE_DEVICE = 'Source Device ID'
  TIMESTAMP = 'Timestamp (YYYY-MM-DDThh:mm:ss)'
  TRANSMITTER_ID = 'Transmitter ID'
  TRANSMITTER_TIME = 'Transmitter Time (Long Integer)'
  TYPE = 'Event Type'

  GLUCOSE_EVENT_TYPE = 'EGV'

  def initialize(content)
    @content = content
  end

  def parse
    cgm_data = Health::Dexcom::CgmData.new
    cgm_data.entries = parse_entries

    cgm_data
  end

  private

  def csv_content
    @csv_content ||= CSV.parse(content, headers: true)
  end

  def parse_entries
    csv_content
      .lazy
      .select { |entry| glucose_entry?(entry) }
      .map { |entry| parse_entry(entry) }
      .to_a
  end

  def parse_entry(entry)
    glucose_entry = Health::Dexcom::GlucoseValueEntry.new

    glucose_entry.glucose_value = entry[GLUCOSE].to_i
    glucose_entry.timestamp = DateTime.parse(entry[TIMESTAMP])
    glucose_entry.transmitter_time = entry[TRANSMITTER_TIME].to_i
    glucose_entry.transmitter_id = entry[TRANSMITTER_ID]
    glucose_entry.source_device_id = entry[SOURCE_DEVICE]

    glucose_entry
  end

  def glucose_entry?(entry)
    entry[TYPE] == GLUCOSE_EVENT_TYPE
  end
end
