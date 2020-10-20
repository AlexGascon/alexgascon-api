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
    #{message_header}

    The alarm "#{alarm.name}" has changed to "#{alarm.state}"

    Reason:
    #{alarm.reason}
    MSG
  end

  def message_header
    case alarm.state.upcase
    when "OK"
      "#{Emojis::WHITE_CHECK_MARK} All good! #{Emojis::WHITE_CHECK_MARK}"
    else
      "#{Emojis::BELL} Alarm! Alarm! #{Emojis::BELL}"
    end
  end
end
