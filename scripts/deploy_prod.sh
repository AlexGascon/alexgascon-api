echo "Deploying to AWS..."
bundle exec jets deploy production

echo "Creating the new DynamoDB tables..."
JETS_ENV=production bundle exec rake dynamoid:create_tables

echo "Updating the CloudFormation stacks..."
for template_path in infrastructure/*
do
	filename=${template_path%.yml}
	stack_name=${filename#infrastructure/}

	echo "Updating stack $stack_name..."
	aws cloudformation deploy \
		--template-file "$template_path" \
		--stack-name "alexgascon-api-$stack_name" \
		--no-fail-on-empty-changeset
done
