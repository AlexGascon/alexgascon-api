# frozen_string_literal: true

class Alarm
  attr_accessor :description, :name, :reason, :state

  STATE_ALARM = 'ALARM'
  STATE_OK = 'OK'
  STATE_INSUFFICIENT_DATA = 'INSUFFICIENT_DATA'
  POSSIBLE_STATES = {
    alarm: STATE_ALARM,
    ok: STATE_OK,
    insufficient_data: STATE_INSUFFICIENT_DATA
  }

  POSSIBLE_STATES.each do |name, value|
    define_method "#{name}?" do
      state == value
    end

    define_method "#{name}!" do
      self.state = value
    end
  end
end
