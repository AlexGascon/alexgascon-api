# frozen_string_literal: true

FactoryBot.define do
  factory :glucose_value, class: Health::GlucoseValue do
    value     { 95 }
    timestamp { DateTime.now - 1.day }
  end
end
