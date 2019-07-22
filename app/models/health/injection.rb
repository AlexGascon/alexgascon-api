# frozen_string_literal: true

module Health
  class Injection < ::ApplicationRecord
    enum injection_type: %i[basal bolus]
  end
end
