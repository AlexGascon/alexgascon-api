# frozen_string_literal: true

class DynamoidHelper
  def self.create_tables
    load_models

    Dynamoid.included_models.each(&:create_table)
  end

  private

  def load_models
    Dir[File.join(Dynamoid::Config.models_dir, '**/*.rb')].sort.each { |file| require file }
  end
end
