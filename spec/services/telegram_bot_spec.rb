# frozen_string_literal: true

RSpec.describe TelegramBot do
  before do
    allow(Telegram::Bot::Client)
      .to receive(:run)
      .and_return(instance_double(Telegram::Bot::Client))
  end

  around do |example|
    with_modified_env(TELEGRAM_CHAT_ID: '123456') { example.run }
  end

  subject { described_class.new }

  describe '#send_message' do
    let(:message) { 'Hey, this is a message!' }
    let(:sent_message_object) { load_json_fixture('telegram/telegram_message.json') }

    before do
      allow(subject).to receive_message_chain(:bot, :api, :send_message) { sent_message_object }
    end

    it 'sends the message' do
      expect(subject)
        .to receive_message_chain(:bot, :api, :send_message)
        .with(chat_id: '123456', parse_mode: 'MarkdownV2', text: message)

      subject.send_message message
    end

    it 'returns the message object' do
      expect(subject.send_message('something')).to eq sent_message_object
    end

    context 'when the message contains special characters' do
      let(:message) { 'Hey... This is a -message- with $pecial characters /{}' }

      it 'escapes the special characters' do
        escaped_message = 'Hey\.\.\. This is a \-message\- with \$pecial characters \/\{\}'
        expect(subject)
          .to receive_message_chain(:bot, :api, :send_message)
          .with(chat_id: '123456', parse_mode: 'MarkdownV2', text: escaped_message)

        subject.send_message message
      end
    end
  end

  describe '#send_photo' do
    let(:photo_url) { 'https://photourl.com' }
    let(:sent_photo_message) { load_json_fixture('telegram/telegram_photo.json') }

    before do
      allow(subject).to receive_message_chain(:bot, :api, :send_photo) { sent_photo_message }
    end

    it 'sends the photo' do
      expect(subject)
        .to receive_message_chain(:bot, :api, :send_photo)
        .with(chat_id: '123456', photo: photo_url)

      subject.send_photo photo_url
    end

    it 'returns the sent message' do
      expect(subject.send_photo(photo_url)).to eq sent_photo_message
    end
  end
end
