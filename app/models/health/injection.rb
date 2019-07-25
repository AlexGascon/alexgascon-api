# frozen_string_literal: true

module Health
  class Injection
    include Dynamoid::Document

    field :injection_type, :string
    field :notes, :string
    field :units, :number

    validates_presence_of :injection_type
    validates_presence_of :units
  end
end
