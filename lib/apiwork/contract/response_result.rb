# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseResult
      attr_reader :response,
                  :issues

      def initialize(response:, issues: [])
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
