# frozen_string_literal: true

class SnsParser
  attr_reader :event

  def initialize(event)
    @event = JSON.parse(event).with_indifferent_access
  end
end
