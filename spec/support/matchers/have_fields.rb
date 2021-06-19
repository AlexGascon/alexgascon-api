RSpec::Matchers.define :have_fields do |fields|
  match do |actual|
    fields.all? { |field, expected_value| actual.send(field) == expected_value }
  rescue NoMethodError
    false
  end
end

RSpec::Matchers.alias_matcher :fields_with_values, :have_fields
