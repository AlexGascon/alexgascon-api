# frozen_string_literal: true

class DynamoidHelper
  def self.create_tables
    Dynamoid.included_models.each do |model|
      model.create_table
    end
  end
end
