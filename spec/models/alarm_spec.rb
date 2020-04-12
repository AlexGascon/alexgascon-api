# frozen_string_literal: true

RSpec.describe Alarm do
  subject { described_class.new }

  describe 'state' do
    states = {
      alarm: 'ALARM',
      ok: 'OK',
      insufficient_data: 'INSUFFICIENT_DATA'
    }

    states.each do |state, value|
      it "#{state}! sets the state to #{value}" do
        method = "#{state}!".to_sym
        subject.send(method)

        expect(subject.state).to eq value
      end

      it "#{state}? verifies that the state is #{value}" do 
        method = "#{state}?".to_sym
        expect(subject.send(method)).to be false

        subject.state = value

        expect(subject.send(method)).to be true
      end
    end
  end
end