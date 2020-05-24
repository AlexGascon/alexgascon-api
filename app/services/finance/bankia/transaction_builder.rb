# frozen_string_literal: true

module Finance
  module Bankia
    class TransactionBuilder < ::Finance::BaseTransactionBuilder
      private

      def amount_in_cents
        @transaction_information['quantity']
      end

      def bank
        'Bankia'
      end

      def internal_id
        @transaction_information['id']
      end

      def transaction_datetime
        Date.parse(@transaction_information['userDate'])
      end

      def description
        @transaction_information['description']
      end
    end
  end
end
