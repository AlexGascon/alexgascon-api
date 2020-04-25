# frozen_string_literal: true

class AlarmReceivedJob < ApplicationJob
  sns_event 'AlarmFired'
  def run
    SendTelegramMessageCommand.new(telegram_message).execute
  end

  private

  def alarm
    @alarm ||= AlarmParser.new(event).parse
  end

  def telegram_message
    <<~MSG
    #{Emojis::BELL} Alarm! Alarm! #{Emojis::BELL}

    The alarm "#{alarm.name}" has changed to "#{alarm.state}"

    Reason:
    #{alarm.reason}
    MSG
  end
end
