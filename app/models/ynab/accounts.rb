# frozen_string_literal: true

module Ynab
  module Accounts
    AIB = 'AIB'
    OPENBANK = 'Openbank'

    DEFAULT = AIB

    ACCOUNT_IDS = {
      AIB => '52b9fb9e-43fd-4610-a2be-7ced8c8c7fe4',
      OPENBANK => 'ee318949-69b9-42cd-9b07-1dfebf9bbd37'
    }.freeze

    def self.get_id(account = nil)
      ACCOUNT_IDS[account] || ACCOUNT_IDS[DEFAULT]
    end
  end
end
