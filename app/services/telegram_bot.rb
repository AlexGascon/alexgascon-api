# frozen_string_literal: true

require 'telegram/bot'

class TelegramBot
  MARKDOWN_MODE = 'MarkdownV2'
  RESERVED_CHARACTERS = '.$%-{}\/'

  def initialize
    @bot = Telegram::Bot::Client.run(bot_token) { |bot| bot }
  end

  def send_message(message)
    escaped_message = message
                      .each_char
                      .map { |char| escape_character(char) }
                      .join

    bot.api.send_message(chat_id: chat_id, text: escaped_message, parse_mode: MARKDOWN_MODE)
  end

  def send_photo(url)
    bot.api.send_photo(chat_id: chat_id, photo: url)
  end

  private

  attr_reader :bot

  def bot_id
    ENV['TELEGRAM_BOT_ID']
  end

  def bot_token
    ENV['TELEGRAM_BOT_TOKEN']
  end

  def chat_id
    ENV['TELEGRAM_CHAT_ID']
  end

  def escape_character(char)
    return "\\#{char}" if RESERVED_CHARACTERS.include? char

    char
  end
end
