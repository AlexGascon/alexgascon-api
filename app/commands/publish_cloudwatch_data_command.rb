# frozen_string_literal: true

class PublishCloudwatchDataCommand
  attr_reader :publishable

  def initialize(publishable)
    @publishable = publishable
  end

  def execute
    cloudwatch.publish(publishable)
  end

  private

  def cloudwatch
    @cloudwatch ||= AwsServices::CloudwatchWrapper.new
  end
end
