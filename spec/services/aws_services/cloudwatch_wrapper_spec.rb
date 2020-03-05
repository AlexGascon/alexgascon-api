# frozen_string_literal: true

RSpec.describe AwsServices::CloudwatchWrapper do
  let(:metrics_service) { instance_double(Aws::CloudWatch::Client) }

  before do
    allow(Aws::CloudWatch::Client).to receive(:new).and_return metrics_service
  end

  subject { described_class.new }

  describe '#publish_injection' do
    before { allow(metrics_service).to receive(:put_metric_data) }

    it 'publishes the injection in CloudWatch' do
      injection = Health::Injection.new(units: 22, injection_type: Health::Injection::TYPE_BASAL, notes: 'test injection')
      expected_metric_data = {
        namespace: 'Health',
        metric_data: [Metrics::InjectionMetric.new(injection)]
      }

      expect(metrics_service).to receive(:put_metric_data).with(expected_metric_data)
      subject.publish_injection(injection)
    end
  end

  describe '#publish_expense' do
    before { allow(metrics_service).to receive(:put_metric_data) }

    it 'publishes the expense in CloudWatch' do
      expense = Finance::Expense.new(amount: 42, category: 'eating out', notes: 'test expense note')
      expected_metric_data = {
        namespace: 'Finance',
        metric_data: [Metrics::ExpenseMetric.new(expense)]
      }

      expect(metrics_service).to receive(:put_metric_data).with(expected_metric_data)
      subject.publish_expense(expense)
    end
  end

  describe '#retrieve_insulin_last_day_image' do
    let(:get_metric_widget_image_response) { Aws::CloudWatch::Types::GetMetricWidgetImageOutput.new(metric_widget_image: image_body) }
    let(:image_body) { 'imagebody' }
    let(:image_url) { 'https://my.image.com/url' }

    before do
      allow(metrics_service).to receive(:get_metric_widget_image).and_return(get_metric_widget_image_response)
      allow_any_instance_of(AwsServices::S3Wrapper).to receive(:store_image).and_return(image_url)
      allow_any_instance_of(TelegramBot).to receive(:send_photo)
    end

    it 'gets the summary image' do
      expect(metrics_service)
        .to receive(:get_metric_widget_image)

      subject.retrieve_insulin_last_day_image
    end

    it 'stores the image in S3' do
      expect_any_instance_of(AwsServices::S3Wrapper)
        .to receive(:store_image)
        .with image_body

      subject.retrieve_insulin_last_day_image
    end

    it 'returns the image URL' do
      expect(subject.retrieve_insulin_last_day_image).to eq image_url
    end
  end
end
