# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      attr_reader :action_name,
                  :contract_class

      class << self
        def parse(contract_class, action_name, request, coerce: false)
          new(contract_class, action_name).parse(request, coerce:)
        end
      end

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name.to_sym
      end

      def parse(request, coerce: false)
        request = coerce_request(request) if coerce

        parsed_query, query_issues = parse_part(request.query, :query)
        parsed_body, body_issues = parse_part(request.body, :body)

        Result.new(
          issues: query_issues + body_issues,
          request: Request.new(body: parsed_body, query: parsed_query),
        )
      end

      private

      def coerce_request(request)
        request
          .transform_query { |query| coerce(query, shape_for(:query)) }
          .transform_body { |body| coerce(body, shape_for(:body)) }
      end

      def parse_part(data, part_type)
        shape = shape_for(part_type)
        return [{}, []] if shape.nil? && data.blank?
        return [data, []] unless shape

        validated = shape.validate(data)

        return [{}, validated.issues] if validated.invalid?

        [shape.transform(shape.deserialize(validated.params)), []]
      end

      def action
        @action ||= contract_class.action_for(action_name)
      end

      def shape_for(part_type)
        case part_type
        when :query
          action&.request&.query
        when :body
          action&.request&.body
        end
      end

      def coerce(data, shape)
        return data unless shape
        return data unless data.is_a?(Hash)

        shape.coerce(data)
      end
    end
  end
end
