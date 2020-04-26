# frozen_string_literal: true

module Health
  class Injection
    include Dynamoid::Document

    delegate :namespace, :data, prefix: :metric, to: :metric_adapter

    TYPE_BASAL = 'basal'
    TYPE_BOLUS = 'bolus'
    TYPES = [TYPE_BASAL, TYPE_BOLUS].freeze

    field :injection_type, :string
    field :notes, :string
    field :units, :number

    validates_presence_of :injection_type
    validates_presence_of :units
    validate :validate_injection_type

    def injection_type=(value)
      self[:injection_type] = value.downcase
    end

    def ==(other)
      other.class == self.class &&
        other.units == units &&
        other.injection_type == injection_type &&
        other.notes == notes
    end

    def metric_adapter
      @metric_adapter ||= Metrics::Health::InjectionMetricAdapter.new(self)
    end

    private

    def validate_injection_type
      errors.add(:injection_type, 'Invalid injection type') unless TYPES.include? injection_type
    end
  end
end
