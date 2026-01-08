# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestResult
      attr_reader :body,
                  :issues,
                  :query

      def initialize(body: {}, issues: [], query: {})
        @body = body
        @issues = issues
        @query = query
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
