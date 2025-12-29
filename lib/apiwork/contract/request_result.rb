# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestResult
      attr_reader :body,
                  :issues,
                  :query

      def initialize(body: {}, issues: [], query: {})
        @issues = issues
        @body = body
        @query = query
      end

      def data
        @data ||= query.merge(body)
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
