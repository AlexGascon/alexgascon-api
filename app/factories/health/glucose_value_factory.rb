class Health::GlucoseValueFactory
  def self.from_dexcom_entry(glucose_value_entry, persist = true)
    creation_method = persist ? :create : :new

    Health::GlucoseValue.send(
      creation_method,
      value: glucose_value_entry.glucose_value, timestamp: glucose_value_entry.timestamp
    )
  end
end
