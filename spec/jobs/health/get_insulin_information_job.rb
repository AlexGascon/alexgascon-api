# frozen_string_literal: true

RSpec.describe Health::GetInsulinInformationJob do
  describe 'get_insulin_information' do
    let(:event) { load_json_fixture('sns_events/health/InsulinInformationRequested.json') }
    let(:mock_cw) { instance_double(AwsServices::CloudwatchWrapper) }
    let(:mock_telegram) { instance_double(TelegramBot) }
    let(:image_url) { 'https://my.image.com/url' }

    subject { described_class.perform_now(:get_insulin_information, event) }

    before do
      allow(AwsServices::CloudwatchWrapper).to receive(:new).and_return(mock_cw)
      allow(mock_cw).to receive(:retrieve_insulin_last_day_image).and_return(image_url)

      allow(TelegramBot).to receive(:new).and_return(mock_telegram)
      allow(mock_telegram).to receive(:send_photo)
    end

    it 'obtains the image for the last 24h of metrics' do
      expect(mock_cw).to receive(:retrieve_insulin_last_day_image)

      subject
    end

    it 'sends the image to Telegram' do
      expect(mock_telegram).to receive(:send_photo).with(image_url)

      subject
    end
  end
end
