# frozen_string_literal: true

RSpec.describe Finance::ExpenseCreatedJob do
  describe 'run' do
    let(:mock_cw) { instance_double(AwsServices::CloudwatchWrapper) }
    let(:fixture) { 'aws/dynamodb/expense_created' }
    let(:event) { load_json_fixture fixture }

    subject { described_class.perform_now(:run, event) }

    before do
      create(:dynamodb_event_expense)

      allow(AwsServices::CloudwatchWrapper).to receive(:new).and_return(mock_cw)
      allow(mock_cw).to receive(:publish).and_return({})

      allow(Airtable::ExpensePublisher).to receive(:publish)
      allow(Ynab::ExpensePublisher).to receive(:publish)
    end

    it 'publishes the expense in CloudWatch' do
      expect(mock_cw).to receive(:publish)

      subject
    end

    it 'publishes the expense in YNAB' do
      expect(Ynab::ExpensePublisher).to receive(:publish)

      subject
    end

    it 'publishes the expense in Airtable' do
      expect(Airtable::ExpensePublisher).to receive(:publish)

      subject
    end
  end
end
