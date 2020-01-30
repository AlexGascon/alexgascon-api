# frozen_string_literal: true

module Health
  class Injection
    include Dynamoid::Document

    field :injection_type, :string
    field :notes, :string
    field :units, :number

    validates_presence_of :injection_type
    validates_presence_of :units

    def ==(other)
      other.class == self.class &&
        other.units == self.units &&
        other.injection_type == self.injection_type &&
        other.notes == self.notes
    end
  end
end
