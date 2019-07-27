# frozen_string_literal: true

class SnsParser
  attr_reader :event

  def initialize(event)
    sns_payload = event['Records'].first['Sns']
    @event = JSON.parse(sns_payload['Message']).with_indifferent_access
  end
end
