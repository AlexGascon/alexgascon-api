namespace :temp do
  desc 'Rename the CloudFormation Alarms stack to specify the alarms category'
  task rename_cloudformation_alarms_stack: :environment do
    cfn = Aws::CloudFormation::Client.new

    # CloudFormation doesn't allow Stack renaming, so we need to delete and recreate
    Jets.logger.info 'Deleting the existing stack...'
    cfn.delete_stack(stack_name: 'alexgascon-api-Alarms')

    # Waiting time for the stack to be deleted
    Jets.logger.info 'Waiting 5 minutes for the stack to be deleted...'
    sleep(300)

    Jets.logger.info 'Creating the new stack...'
    cfn.create_stack(
      stack_name: 'alexgascon-api-Alarms-Infrastructure',
      template_body: File.read("#{Jets.root}/infrastructure/Alarms-Infrastructure.yml")
    )
  end
end
