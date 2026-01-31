# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseResult
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
