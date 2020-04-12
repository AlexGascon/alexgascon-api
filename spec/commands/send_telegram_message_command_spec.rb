# frozen_string_literal: true

RSpec.describe SendTelegramMessageCommand do
  describe 'execute' do
    before { allow_any_instance_of(TelegramBot).to receive(:send_message) }

    it 'sends a telegram message' do
      message = 'Hey, this is a Telegram message'
      command = described_class.new(message)

      expect_any_instance_of(TelegramBot).to receive(:send_message).with(message)

      command.execute
    end
  end
end
