# frozen_string_literal: true

module Finance
  class ExpenseCreatedJob < ::ApplicationJob

    dynamodb_event 'alexgascon-api_production_expenses'
    def run
      Jets.logger.info "DynamoDB event: #{event}"

      expenses
        .each { |expense| publish_expense_metric(expense) }
        .each { |expense| publish_expense_in_airtable(expense) }
        .each { |expense| publish_expense_in_ynab(expense) }

      expenses
    end

    private

    def expenses
      @expenses ||= parse_expenses
    end

    def publish_expense_metric(expense)
      AwsServices::CloudwatchWrapper.new.publish(expense)
    end

    def publish_expense_in_airtable(expense)
      Airtable::ExpensePublisher.publish(expense)
    end

    def publish_expense_in_ynab(expense)
      Ynab::ExpensePublisher.publish(expense)
    end

    def parse_expenses
      event['Records']
        .select { |record| new_transaction?(record) }
        .map { |record| record['dynamodb'] }
        .map { |dynamodb_record| extract_expense_id(dynamodb_record) }
        .map { |expense_id| find_expense(expense_id) }
    end

    def new_transaction?(record)
      record.has_key?('dynamodb') && record['eventName'] == 'INSERT'
    end

    def extract_expense_id(dynamodb_record)
      dynamodb_record.dig('Keys', 'id', 'S')
    end

    def find_expense(expense_id)
      Finance::Expense.find(expense_id)
    end
  end
end
