# frozen_string_literal: true

module Finance::ExpenseClassification
  module Rules
    ALL = Dir
          .entries("#{__dir__}/rules/")
          .select { |filename| filename.ends_with?('.rb') && filename != 'base_rule.rb' }
          .map { |filename| filename.delete_suffix '.rb' }
          .map(&:camelize)
          .map { |class_name| const_get(class_name) }
  end
end
