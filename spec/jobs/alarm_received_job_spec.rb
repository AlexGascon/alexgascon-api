# frozen_string_literal: true

RSpec.describe AlarmReceivedJob do
  subject { described_class.perform_now(:run, event) }

  describe 'run' do
    before { stub_command(SendTelegramMessageCommand) }

    let(:event) { load_json_fixture('sns_events/cloudwatch_alarm_alarm') }

    it 'sends a Telegram message' do
      expect_any_instance_of(SendTelegramMessageCommand).to receive(:execute)

      subject
    end

    context 'when the alarm has changed to ALARM state' do
      let(:event) { load_json_fixture('sns_events/cloudwatch_alarm_alarm') }

      it 'passes an alarm message to the command' do
        expected_message = <<~MSG
        \xF0\x9F\x94\x94 Alarm! Alarm! \xF0\x9F\x94\x94

        The alarm "Example alarm name" has changed to "ALARM"

        Reason:
        Threshold Crossed: 1 datapoint (10.0) was greater than or equal to the threshold (1.0).
        MSG

        expect(SendTelegramMessageCommand).to receive(:new).with(expected_message)

        subject
      end
    end

    context 'when the alarm has changed to OK state' do
      let(:event) { load_json_fixture('sns_events/cloudwatch_alarm_ok') }

      it 'passes an OK message to the command' do
        expected_message = <<~MSG
        \xE2\x9C\x85 All good! \xE2\x9C\x85

        The alarm "Example alarm name" has changed to "OK"

        Reason:
        Threshold Crossed: 1 datapoint (0.5) was not greater than or equal to the threshold (1.0).
        MSG

        expect(SendTelegramMessageCommand).to receive(:new).with(expected_message)

        subject
      end
    end
  end
end
