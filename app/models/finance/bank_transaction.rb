# frozen_string_literal: true

module Finance
  class BankTransaction
    include Dynamoid::Document
    include Metricable

    AIB = 'AIB'
    OPENBANK = 'Openbank'
    VALID_BANKS = [AIB, OPENBANK].freeze

    ERROR_BANK_INVALID = 'The specified bank is not allowed'
    ERROR_INTERNAL_ID_BLANK = 'internal_id cannot be blank if the bank is present'

    field :amount_in_cents, :number
    field :bank, :string
    field :datetime, :datetime
    field :description, :string
    field :internal_id, :string

    # Indexes
    field :year_month, :string
    field :day, :string

    global_secondary_index hash_key: :year_month, range_key: :day, projected_attributes: :all, name: 'transaction_date', read_capacity: 1, write_capacity: 1
    global_secondary_index hash_key: :internal_id

    validates_presence_of :amount_in_cents
    validates_presence_of :datetime
    validates_presence_of :description
    validate :bank_information_is_valid?

    def amount
      (amount_in_cents / 100).round(2)
    end

    def expense?
      amount_in_cents.negative?
    end

    def bank_information_is_valid?
      return if bank.blank?

      errors.add(:bank, ERROR_BANK_INVALID) unless bank_is_valid?
      errors.add(:internal_id, ERROR_INTERNAL_ID_BLANK) if internal_id.blank?
    end

    def to_s
      "Finance::BankTransaction(description: #{description}, amount: #{amount}, bank: #{bank}, datetime: #{datetime})"
    end

    private

    def bank_is_valid?
      VALID_BANKS.include? bank
    end
  end
end
