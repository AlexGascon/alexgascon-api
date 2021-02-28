# frozen_string_literal: true

RSpec.describe Airtable::ExpensePublisher do
  let(:finance_expense) do
    Finance::Expense.new(
      amount: 12,
      category: Finance::ExpenseCategories::SUPERMARKET,
      notes: 'test injection',
      created_at: Time.now
    )
  end

  describe 'publish' do
    it 'publishes the expense in Airtable' do
      expect_any_instance_of(Airtable::Expense).to receive :save

      Airtable::ExpensePublisher.publish(finance_expense)
    end
  end
end
