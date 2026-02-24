# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseParser
      class Result
        attr_reader :issues,
                    :response

        def initialize(issues: [], response:)
          @response = response
          @issues = issues
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
