# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      class Result
        attr_reader :issues,
                    :request

        def initialize(issues: [], request:)
          @request = request
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
