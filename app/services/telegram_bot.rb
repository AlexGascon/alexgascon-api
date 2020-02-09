# frozen_string_literal: true

require 'telegram/bot'

class TelegramBot
  MARKDOWN_MODE = 'MarkdownV2'

  def initialize
    self.bot = Telegram::Bot::Client.run(bot_token) { |bot| bot }
  end

  def send_message(message)
    bot.api.send_message(chat_id: chat_id, text: message, parse_mode: MARKDOWN_MODE)
  end

  private

  attr_accessor :bot

  def bot_id
    ENV['TELEGRAM_BOT_ID']
  end

  def bot_token
    ENV['TELEGRAM_BOT_TOKEN']
  end

  def chat_id
    ENV['TELEGRAM_CHAT_ID']
  end
end
