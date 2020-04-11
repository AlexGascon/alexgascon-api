echo "Deploying to AWS..."
bundle exec jets deploy production

echo "Creating the new DynamoDB tables..."
JETS_ENV=production bundle exec rake dynamoid:create_tables

echo "Updating the CloudFormation stacks..."
aws cloudformation deploy \
	--template-file infrastructure/alarms.yml \
	--stack-name alexgascon-api-Alarms \
	--no-fail-on-empty-changeset
