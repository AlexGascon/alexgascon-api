# frozen_string_literal: true

FactoryBot.define do
  factory :dexcom_blood_glucose, class: 'Dexcom::BloodGlucose' do
    value { 142 }
    trend { 3 }
    timestamp { DateTime.new(2020, 6, 10, 21, 43, 14, '+00:00') }

    initialize_with { new(value, trend, timestamp) }
  end
end
