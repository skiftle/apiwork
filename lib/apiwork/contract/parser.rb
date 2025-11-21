# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      include Coercion
      include Deserialization
      include Transformation
      include Validation

      attr_reader :contract_class, :action, :direction

      def initialize(contract_class, direction, action, **options)
        @contract_class = contract_class
        @direction = direction.to_sym
        @action = action.to_sym
        @coerce = options.fetch(:coerce, false)
        @context = options[:context] || {}

        validate_direction!
      end

      def action_definition
        @action_definition ||= contract_class.action_definition(action)
      end

      def schema_class
        @schema_class ||= action_definition&.schema_class
      end

      def perform(data)
        coerced_data = @coerce ? coerce(data) : data

        data_for_validation = if @direction == :output && schema_class&.output_key_format
                                coerced_data.deep_transform_keys { |key| key.to_s.underscore.to_sym }
                              else
                                coerced_data
                              end

        validated = validate(data_for_validation)

        if validated[:issues].any? && @direction == :output && schema_class&.output_key_format
          validated[:issues] = transform_paths(validated[:issues], schema_class.output_key_format)
        end

        return handle_validation_errors(data, validated[:issues]) if validated[:issues].any?

        deserialized_data = if @direction == :input
                              apply_deserialize_transformers(validated[:params])
                            else
                              validated[:params]
                            end

        transformed_data = transform(deserialized_data)

        build_result(transformed_data, [])
      end

      private

      def validate_direction!
        return if %i[input output].include?(@direction)

        raise ArgumentError, "direction must be :input or :output, got #{@direction.inspect}"
      end

      def definition
        @definition ||= case direction
                        when :input
                          action_definition&.merged_input_definition
                        when :output
                          action_definition&.merged_output_definition
                        end
      end

      def build_result(data, errors)
        Result.new(data, errors)
      end

      def transform_paths(issues, key_transform)
        issues.map do |issue|
          transformed_path = issue.path.map do |segment|
            next segment if segment.is_a?(Integer)

            case key_transform
            when :camel
              segment.to_s.camelize(:lower).to_sym
            when :underscore
              segment.to_s.underscore.to_sym
            else
              segment
            end
          end

          Issue.new(
            code: issue.code,
            detail: issue.detail,
            path: transformed_path,
            meta: issue.meta
          )
        end
      end
    end
  end
end
