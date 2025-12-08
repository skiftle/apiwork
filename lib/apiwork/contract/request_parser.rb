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

      def perform(query, body)
        query_data, query_issues = parse_part(query, :query)
        body_data, body_issues = parse_part(body, :body)

        RequestResult.new(
          query: query_data,
          body: body_data,
          issues: query_issues + body_issues
        )
      end

      private

      def parse_part(data, part_type)
        definition = definition_for(part_type)
        return [{}, []] if definition.nil? && data.blank?
        return [data, []] unless definition

        coerced_data = @coerce ? coerce(data, definition) : data
        validated = validate(coerced_data, definition)

        return [{}, validated[:issues]] if validated[:issues].any?

        deserialized = deserialize(validated[:params], definition)
        transformed = transform(deserialized, definition)

        [transformed, []]
      end

      def action_definition
        @action_definition ||= contract_class.action_definition(action_name)
      end

      def definition_for(part_type)
        case part_type
        when :query
          action_definition&.request_definition&.query_definition
        when :body
          action_definition&.request_definition&.body_definition
        end
      end

      def coerce(data, definition)
        return data unless data.is_a?(Hash)

        Coercion.coerce_hash(data, definition)
      end

      def validate(data, definition)
        definition.validate(data) || { params: data, issues: [] }
      end

      def deserialize(data, definition)
        return data unless data.is_a?(Hash)

        Deserialization.deserialize_hash(data, definition)
      end

      def transform(data, definition)
        return data unless data.is_a?(Hash)

        Transformation.apply(data, definition)
      end
    end
  end
end
