# frozen_string_literal: true

RSpec.describe AlarmReceivedJob do
  subject { described_class.perform_now(:run, event) }

  describe 'run' do
    before do
      allow(SendTelegramMessageCommand).to receive(:new).and_call_original
      allow_any_instance_of(SendTelegramMessageCommand).to receive :execute
    end

    let(:event) { load_json_fixture('sns_events/cloudwatch_alarm') }

    it 'sends a Telegram message' do
      expect_any_instance_of(SendTelegramMessageCommand).to receive(:execute)

      subject
    end

    it 'passes the correct message to the command' do
      expected_message = <<~MSG
      \xF0\x9F\x94\x94 Alarm! Alarm! \xF0\x9F\x94\x94

      The alarm "Example alarm name" has entered into "ALARM"

      Reason:
      Threshold Crossed: 1 datapoint (10.0) was greater than or equal to the threshold (1.0).
      MSG

      expect(SendTelegramMessageCommand).to receive(:new).with(expected_message)

      subject
    end
  end
end
