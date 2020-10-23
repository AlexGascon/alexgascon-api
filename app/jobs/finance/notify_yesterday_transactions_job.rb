# frozen_string_literal: true

module Finance
  class NotifyYesterdayTransactionsJob < ::ApplicationJob

    cron '27 06 * * ? *'
    def run
      return if yesterday_transactions.empty?

      SendTelegramMessageCommand.new(telegram_message).execute
    end

    private

    def yesterday_transactions
      yesterday = Date.yesterday

      @yesterday_transactions ||=
        Finance::BankTransaction
          .where('year_month': yesterday.strftime('%Y-%m'), 'day.gte': yesterday.strftime('%d'))
          .to_a
    end

    def monthly_transactions
      yesterday_year_month = Date.yesterday.strftime('%Y-%m')

      @monthly_transactions ||=
        Finance::BankTransaction
          .where('year_month': yesterday_year_month)
          .to_a
    end

    def telegram_message
      <<~MSG
      #{Emojis::FLYING_MONEY} #{yesterday_transactions.size} expenses yesterday #{Emojis::FLYING_MONEY}

      #{yesterday_transactions.map { |t| format_transaction(t) }.join("\n\n")}

      Total: #{yesterday_transactions.map(&:amount).sum}€
      Month to date: #{monthly_transactions.map(&:amount).sum}€
      MSG
    end

    def format_transaction(transaction)
      [
        "#{Emojis::MONEY_BAG} #{transaction.amount}€: #{transaction.description}",
        "#{Emojis::BANK} #{transaction.bank}"
      ].join("\n")
    end
  end
end
