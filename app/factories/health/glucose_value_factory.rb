class Health::GlucoseValueFactory
  def self.from_dexcom_entry(glucose_value_entry, persist = true)
    creation_method = persist ? :create : :new

    Health::GlucoseValue.send(
      creation_method,
      value: glucose_value_entry.glucose_value, timestamp: glucose_value_entry.timestamp
    )
  end

  def self.from_dexcom_gem(blood_glucose, persist = true)
    creation_method = persist ? :create : :new

    Health::GlucoseValue.send(
      creation_method,
      value: blood_glucose.value, timestamp: blood_glucose.timestamp
    )
  end

  def self.from_dexcom_gem_entries(blood_glucoses)
    glucose_values_data = blood_glucoses.map { |bg| { value: bg.value, timestamp: bg.timestamp } }

    Jets.logger.warn("WARNING: Health::GlucoseValue.import is faster than individual saves, but doesn't run validations or callbacks")
    Health::GlucoseValue.import(glucose_values_data)
  end
end
