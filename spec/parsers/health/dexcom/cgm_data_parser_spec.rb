# frozen_string_literal: true

RSpec.describe Health::Dexcom::CgmDataParser do
  let(:file_path) { 'spec/fixtures/dexcom/cgm_data.csv' }
  let(:data) { File.read(file_path) }

  subject(:parser) { described_class.new(data) }

  describe 'parse' do
    it 'creates a Health::Dexcom::CgmData object' do
      expect(parser.parse).to be_a(Health::Dexcom::CgmData)
    end

    it 'parses only the EGV entries' do
      cgm_data = parser.parse
      expect(cgm_data.entries.size).to eq 16
    end

    it 'parses the EGV entries correctly' do
      cgm_data = parser.parse
      egv_entry = cgm_data.entries.first

      expected_datetime = DateTime.parse '2020-04-05T00:00:28'

      expect(egv_entry.glucose_value).to eq 86
      expect(egv_entry.timestamp).to eq expected_datetime
      expect(egv_entry.transmitter_time).to eq 5195173
      expect(egv_entry.transmitter_id).to eq '8J525Y'
      expect(egv_entry.source_device_id).to eq 'Android G6'
    end
  end
end
