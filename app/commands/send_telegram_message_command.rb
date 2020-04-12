# frozen_string_literal: true

class SendTelegramMessageCommand
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def execute
    telegram_bot.send_message(message)
  end

  private

  def telegram_bot
    @telegram_bot ||= TelegramBot.new
  end
end
