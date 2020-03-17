echo "Deploying to AWS..."
bundle exec jets deploy production

echo "Creating the new DynamoDB tables..."
JETS_ENV=production bundle exec rake dynamoid:create_tables