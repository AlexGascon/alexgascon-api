# frozen_string_literal: true

module Finance
  class BaseTransactionBuilder
    CENTS_PER_EURO = 100

    def initialize(transaction_information)
      @transaction_information = transaction_information
    end

    def build
      transaction = Finance::BankTransaction.new

      transaction.update_attributes(
        amount_in_cents: amount_in_cents,
        bank: bank,
        internal_id: internal_id,
        datetime: transaction_datetime,
        description: description
      )

      transaction.save!

      transaction
    end
  end
end
