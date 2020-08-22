# frozen_string_literal: true

module Finance
  module Aib
    class TransactionBuilder < ::Finance::BaseTransactionBuilder
      private

      def amount_in_cents
        @transaction_information['amount'] * CENTS_PER_EURO
      end

      def bank
        'AIB'
      end

      def internal_id
        @transaction_information['transaction_id']
      end

      def transaction_datetime
        DateTime.parse(@transaction_information['timestamp']).in_time_zone('Europe/Dublin').to_date
      end

      def description
        @transaction_information['description']
      end
    end
  end
end
