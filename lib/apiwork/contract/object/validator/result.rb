# frozen_string_literal: true

module Apiwork
  module Contract
    class Object
      class Validator
        class Result
          attr_reader :issues,
                      :params

          def initialize(issues: [], params:)
            @issues = issues
            @params = params
          end

          def valid?
            issues.empty?
          end

          def invalid?
            issues.any?
          end
        end
      end
    end
  end
end
