# frozen_string_literal: true

RSpec.describe 'RSpec::Matcher have_fields' do
  class Person
    attr_accessor :age, :name

    def initialize(name, age)
      @name = name
      @age = age
    end
  end

  let(:alex) { Person.new('Alex', 28) }

  it 'matches if all the values match' do
    expect(alex).to have_fields(name: 'Alex', age: 28)
  end

  it 'matches if not all arguments are specified' do
    expect(alex).to have_fields(name: 'Alex')
    expect(alex).to have_fields(age: 28)
  end

  it 'does not match if any value does not match' do
    expect(alex).not_to have_fields(name: 'Paco', age: 28)
  end

  it 'fails if the object does not have that field' do
    expect(alex).not_to have_fields(country: 'Spain')
  end

  it 'is aliased as fields_with_values' do
    expect(alex).to fields_with_values(name: 'Alex', age: 28)
  end
end
