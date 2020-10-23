namespace :temp do
  desc 'Enable DynamoDB streams on the Bank Transactions table'
  task enable_dynamodb_streams_on_banktransaction: :environment do
    dynamodb = Aws::DynamoDB::Client.new

    Jets.logger.info 'Updating the Expenses table...'
    dynamodb.update_table(
      table_name: 'alexgascon-api_production_banktransactions',
      stream_specification: {
        stream_enabled: true,
        stream_view_type: 'NEW_IMAGE'
      }
    )

    Jets.logger.info 'Update operation started!'
    Jets.logger.info 'This is an async operation, so results will not be immediate'
  end
end
