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
        query_data, query_issues = parse_part(query, :query)
        body_data, body_issues = parse_part(body, :body)

        RequestResult.new(
          body: body_data,
          issues: query_issues + body_issues,
          query: query_data,
        )
      end

      private

      def parse_part(data, part_type)
        shape = shape_for(part_type)
        return [{}, []] if shape.nil? && data.blank?
        return [data, []] unless shape

        coerced_data = @coerce ? coerce(data, shape) : data
        validated = validate(coerced_data, shape)

        return [{}, validated[:issues]] if validated[:issues].any?

        deserialized = deserialize(validated[:params], shape)
        transformed = transform(deserialized, shape)

        [transformed, []]
      end

      def action
        @action ||= contract_class.action_for(action_name)
      end

      def shape_for(part_type)
        case part_type
        when :query
          action&.request&.query_param
        when :body
          action&.request&.body_param
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
