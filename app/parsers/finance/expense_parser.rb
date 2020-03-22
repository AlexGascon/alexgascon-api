# frozen_string_literal: true

module Finance
  class ExpenseParser < SnsParser
    def parse
      {
        amount: event[:amount].to_f,
        category: event[:category],
        notes: event[:notes]
      }
    end
  end
end
