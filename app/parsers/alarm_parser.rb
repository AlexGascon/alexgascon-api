# frozen_string_literal: true

class AlarmParser < SnsParser
  def parse
    alarm = Alarm.new

    alarm.name = event['AlarmName']
    alarm.description = event['AlarmDescription']
    alarm.reason = event['NewStateReason']
    alarm.state = event['NewStateValue']

    alarm
  end
end
