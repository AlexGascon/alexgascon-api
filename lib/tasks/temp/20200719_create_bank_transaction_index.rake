namespace :temp do
  desc 'Update the BankTransactions table and create an index on the transaction date'
  task bank_transaction_update_and_index: :environment do
    client = Aws::DynamoDB::Client.new
    table_name = Finance::BankTransaction.table_name

    client.update_table(
      table_name: table_name,
      attribute_definitions: [
        {
          attribute_name: 'year_month',
          attribute_type: 'S',
        },
        {
          attribute_name: 'day',
          attribute_type: 'S'
        }
      ],
      global_secondary_index_updates: [{
        create: {
          index_name: 'transaction_date',
          key_schema: [
            {
              key_type: 'HASH',
              attribute_name: 'year_month'
            },
            {
              key_type: 'RANGE',
              attribute_name: 'day'
            }
          ],
          projection: {
            projection_type: 'ALL'
          },
          provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1
          },
        }
      }]
    )

    errors = 0
    Finance::BankTransaction.batch(50).each do |bank_transaction|
      # Give some time to DynamoDB to avoid getting exceeded capacity errors
      sleep(0.01)

      bank_transaction.year_month = bank_transaction.datetime.strftime('%Y-%m')
      bank_transaction.day = bank_transaction.datetime.strftime('%d')
      bank_transaction.save!
    rescue e
      errors += 1      
      puts "Error: #{e}"
    end

    puts "Encountered #{errors} errors while updating existing BankTransactions"
  end
end