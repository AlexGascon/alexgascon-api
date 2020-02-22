# frozen_string_literal: true

module Health
  class GetInsulinInformationJob < ::ApplicationJob

    sns_event 'InsulinInformationRequested'
    def get_insulin_information
      image_url = cloudwatch.retrieve_insulin_last_day_image
      telegram.send_photo(image_url)
    end

    private

    def cloudwatch
      @cloudwatch ||= AwsServices::CloudwatchWrapper.new
    end

    def telegram
      @telegram ||= TelegramBot.new
    end
  end
end
