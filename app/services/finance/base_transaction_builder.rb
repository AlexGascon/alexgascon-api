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
        description: description,
        year_month: year_month,
        day: day
      )

      transaction.save!

      transaction
    end

    private

    def year_month
      transaction_datetime.strftime('%Y-%m')
    end

    def day
      transaction_datetime.strftime('%d')
    end
  end
end
