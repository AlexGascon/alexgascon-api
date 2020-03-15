# frozen_string_literal: true

module Finance
  module Openbank
    class TransactionBuilder < ::Finance::BaseTransactionBuilder
      private

      def amount_in_cents
        @transaction_information['importe']['importe'] * CENTS_PER_EURO
      end

      def bank
        'Openbank'
      end

      def internal_id
        general_id = @transaction_information['operacionDGO']['codigoterminaldgo']
        transaction_id = @transaction_information['operacionDGO']['numerodgo']

        "#{general_id}_#{transaction_id}"
      end

      def transaction_datetime
        DateTime.parse(@transaction_information['fechaOperacion'])
      end

      def description
        @transaction_information['conceptoTabla'].strip
      end
    end
  end
end
