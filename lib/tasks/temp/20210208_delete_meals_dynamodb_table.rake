namespace :temp do
  desc 'Delete Meals table in DynamoDB'
  task delete_meals_dynamodb_table: :environment do
    dynamodb = Aws::DynamoDB::Client.new

    Jets.logger.info 'Deleting Meals table...'
    dynamodb.delete_table(
      table_name: 'alexgascon-api_production_meals',
    )

    Jets.logger.info 'Operation completed. Verify in the AWS Console if it completed successfully'
  end
end
