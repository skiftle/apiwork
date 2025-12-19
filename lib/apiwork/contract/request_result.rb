# frozen_string_literal: true

module Apiwork
  module Contract
    # @api private
    class RequestResult
      attr_reader :body,
                  :issues,
                  :query

      def initialize(query:, body:, issues:)
        @query = query
        @body = body
        @issues = issues
      end

      def data
        @data ||= (query || {}).merge(body || {})
      end

      def [](key)
        data[key]
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
