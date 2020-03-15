# frozen_string_literal: true

module Finance
  class BankTransaction
    include Dynamoid::Document

    OPENBANK = 'Openbank'
    VALID_BANKS = [OPENBANK].freeze

    field :amount_in_cents, :number
    field :bank, :string
    field :datetime, :datetime
    field :description, :string
    field :internal_id, :string

    global_secondary_index hash_key: :internal_id

    validates_presence_of :amount_in_cents
    validates_presence_of :datetime
    validates_presence_of :description
    validate :bank_information_is_valid?

    def expense?
      amount_in_cents.negative?
    end

    def bank_information_is_valid?
      return if bank.blank?

      errors.add(:bank, 'The specified bank is not allowed') unless bank_is_valid?
      errors.add(:internal_id, 'internal_id cannot be blank if the bank is specified') if internal_id.blank?
    end

    private

    def bank_is_valid?
      VALID_BANKS.include? bank
    end
  end
end
