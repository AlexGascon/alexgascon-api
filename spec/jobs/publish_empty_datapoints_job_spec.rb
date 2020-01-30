# frozen_string_literal: true

RSpec.describe PublishEmptyDatapointsJob do
  let(:mock_cw) { instance_double(AwsServices::CloudwatchWrapper) }

  before do
    allow(AwsServices::CloudwatchWrapper).to receive(:new).and_return(mock_cw)
    allow(mock_cw).to receive(:publish_expense)
    allow(mock_cw).to receive(:publish_injection)
  end

  RSpec.shared_examples 'empty injection metrics' do |type|
    it "publishes an empty #{type} injection" do
      empty_injection = Health::Injection.new(injection_type: type, units: 0)
      expect(mock_cw).to receive(:publish_injection).with(empty_injection)

      subject
    end
  end

  RSpec.shared_examples 'empty expense metrics' do |category|
    it "publishes an empty #{category} expense" do
      empty_expense = Finance::Expense.new(amount: 0, notes: nil, category: category)
      expect(mock_cw).to receive(:publish_expense).with(empty_expense)

      subject
    end
  end

  describe '#publish' do
    subject { described_class.perform_now(:publish) }

    context 'injections' do
      INJECTION_TYPES = ['basal', 'bolus']

      INJECTION_TYPES.each do |injection_type|
        include_examples 'empty injection metrics', injection_type
      end
    end

    context 'expenses' do
      Finance::ExpenseCategories::ALL.each do |category|
        include_examples 'empty expense metrics', category
      end
    end
  end
end
