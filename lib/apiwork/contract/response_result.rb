# frozen_string_literal: true

module Apiwork
  module Contract
    # @api private
    class ResponseResult
      attr_reader :body,
                  :issues

      def initialize(body, issues)
        @body = body
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
