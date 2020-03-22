# frozen_string_literal: true

module Ynab
  module Accounts
    AIB = 'AIB'
    BANKIA = 'Bankia'
    OPENBANK = 'Openbank'

    DEFAULT = AIB

    ACCOUNT_IDS = {
      AIB => 'e1a73ac1-62aa-4c12-a012-040982104623',
      BANKIA => '8c36cf6d-fac1-4517-a501-7287955d8706',
      OPENBANK => 'ba3e4149-19e0-404d-a5c1-2c1878005ac6'
    }.freeze

    def self.get_id(account = nil)
      ACCOUNT_IDS[account] || ACCOUNT_IDS[DEFAULT]
    end
  end
end
