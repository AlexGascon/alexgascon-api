# frozen_string_literal: true

module Finance
  class NotifyYesterdayTransactionsJob < ::ApplicationJob

    cron '27 12 * * ? *'
    def run
      return if yesterday_transactions.empty?

      SendTelegramMessageCommand.new(telegram_message).execute
    end

    private

    def yesterday_transactions
      @yesterday_transactions ||= Finance::BankTransaction.where('datetime.gte': Date.yesterday).to_a
    end

    def telegram_message
      <<~MSG
      #{Emojis::FLYING_MONEY} #{yesterday_transactions.size} expenses yesterday #{Emojis::FLYING_MONEY}

      #{yesterday_transactions.map { |t| format_transaction(t) }.join("\n\n")}

      Total: #{yesterday_transactions.map(&:amount).sum}€
      MSG
    end

    def format_transaction(transaction)
      "#{Emojis::MONEY_BAG} #{transaction.amount}€: #{transaction.description}"
    end
  end
end
