# frozen_string_literal: true

RSpec.describe Metrics::Finance::BankTransactionMetricAdapter do
  let(:bank_transaction) { FactoryBot.create(:bank_transaction) }
  let(:metric) { subject }

  subject { described_class.new(bank_transaction) }

  it 'sets the metric namespace' do
    expect(metric.namespace).to eq 'Finance'
  end

  it 'sets the metric name' do
    expect(metric.metric_name).to eq 'BankTransaction'
  end

  it 'sets the metric value' do
    expect(metric.value).to eq -42
  end

  it 'sets the timestamp' do
    expect(metric.timestamp).to eq bank_transaction.datetime
  end

  it 'sets only one dimension' do
    expect(metric.dimensions.size).to eq 1
  end

  it 'sets the "Bank" dimension' do
    dimension = metric.dimensions.first
    expect(dimension[:name]).to eq 'Bank'
    expect(dimension[:value]).to eq 'Openbank'
  end
end
