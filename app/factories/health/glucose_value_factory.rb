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
end
