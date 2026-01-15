# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      attr_reader :action_name,
                  :contract_class

      def initialize(contract_class, action_name, coerce: false)
        @contract_class = contract_class
        @action_name = action_name.to_sym
        @coerce = coerce
      end

      def parse(query, body)
        parsed_query, query_issues = parse_part(query, :query)
        parsed_body, body_issues = parse_part(body, :body)

        RequestResult.new(
          body: parsed_body,
          issues: query_issues + body_issues,
          query: parsed_query,
        )
      end

      private

      def parse_part(data, part_type)
        shape = shape_for(part_type)
        return [{}, []] if shape.nil? && data.blank?
        return [data, []] unless shape

        validated = validate(@coerce ? coerce(data, shape) : data, shape)

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
        return data unless data.is_a?(Hash)

        Coercion.coerce_hash(data, shape)
      end

      def validate(data, shape)
        shape.validate(data) || { issues: [], params: data }
      end

      def deserialize(data, shape)
        return data unless data.is_a?(Hash)

        Deserialization.deserialize_hash(data, shape)
      end

      def transform(data, shape)
        return data unless data.is_a?(Hash)

        Transformation.apply(data, shape)
      end
    end
  end
end
