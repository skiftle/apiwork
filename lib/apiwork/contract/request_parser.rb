# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      attr_reader :action_name,
                  :contract_class

      def self.parse(contract_class, action_name, request, coerce: false)
        new(contract_class, action_name).parse(request, coerce:)
      end

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name.to_sym
      end

      def parse(request, coerce: false)
        request = coerce_request(request) if coerce

        parsed_query, query_issues = parse_part(request.query, :query)
        parsed_body, body_issues = parse_part(request.body, :body)

        ParseResult.new(
          issues: query_issues + body_issues,
          request: Request.new(body: parsed_body, query: parsed_query),
        )
      end

      private

      def coerce_request(request)
        request
          .transform_query { |q| coerce(q, shape_for(:query)) }
          .transform_body { |b| coerce(b, shape_for(:body)) }
      end

      def parse_part(data, part_type)
        shape = shape_for(part_type)
        return [{}, []] if shape.nil? && data.blank?
        return [data, []] unless shape

        validated = validate(data, shape)

        return [{}, validated[:issues]] if validated[:issues].any?

        [transform(deserialize(validated[:params], shape), shape), []]
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

        Coercer.coerce(shape, data)
      end

      def validate(data, shape)
        shape.validate(data) || { issues: [], params: data }
      end

      def deserialize(data, shape)
        return data unless data.is_a?(Hash)

        Deserializer.deserialize(shape, data)
      end

      def transform(data, shape)
        return data unless data.is_a?(Hash)

        Transformer.transform(shape, data)
      end
    end
  end
end
