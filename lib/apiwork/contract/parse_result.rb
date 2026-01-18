# frozen_string_literal: true

module Apiwork
  module Contract
    # Result from parsing and validating a request.
    #
    # @see RequestParser
    class ParseResult
      # @return [Adapter::Request] the parsed request with validated data
      attr_reader :request

      # @return [Array<Issue>] validation issues (empty if valid)
      attr_reader :issues

      def initialize(issues:, request:)
        @request = request
        @issues = issues
      end

      # @return [Boolean] true if no validation issues
      def valid?
        issues.empty?
      end
    end
  end
end
