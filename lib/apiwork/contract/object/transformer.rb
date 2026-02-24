# frozen_string_literal: true

module Apiwork
  module Contract
    class Object
      class Transformer
        class << self
          def transform(shape, params)
            new(shape).transform(params)
          end
        end

        def initialize(shape)
          @shape = shape
        end

        def transform(params)
          return params unless params.is_a?(Hash)

          transformed = params.dup

          @shape.params.each do |name, param_options|
            next unless transformed.key?(name)

            value = transformed[name]

            if param_options[:as]
              transformed[param_options[:as]] = transformed.delete(name)
              name = param_options[:as]
              value = transformed[name]
            end

            if param_options[:shape] && value.is_a?(Hash)
              transformed[name] = Transformer.transform(param_options[:shape], value)
            elsif param_options[:type] == :array && value.is_a?(Array)
              of = param_options[:of]
              of_shape = of&.shape

              if of_shape
                transformed[name] = value.map do |item|
                  item.is_a?(Hash) ? Transformer.transform(of_shape, item) : item
                end
              elsif of && (array_result = transform_custom_type_array(value, param_options))
                transformed[name] = array_result
              end
            end
          end

          transformed
        end

        private

        def transform_custom_type_array(value, param_options)
          of = param_options[:of]
          type_name = of&.type
          custom_type_shape = resolve_custom_type_shape(type_name)
          return nil unless custom_type_shape

          value.map do |item|
            item.is_a?(Hash) ? Transformer.transform(custom_type_shape, item) : item
          end
        end

        def resolve_custom_type_shape(type_name)
          contract_class = @shape.contract_class
          type_definition = contract_class.resolve_custom_type(type_name)
          return nil unless type_definition

          scope_contract_class = type_definition.scope || contract_class

          if type_definition.object?
            build_type_shape(type_definition, scope_contract_class)
          elsif type_definition.union?
            first_variant = type_definition.variants.first
            return nil unless first_variant

            variant_type_definition = scope_contract_class.resolve_custom_type(first_variant[:type])
            return nil unless variant_type_definition
            return nil unless variant_type_definition.object?

            variant_contract_class = variant_type_definition.scope || scope_contract_class
            build_type_shape(variant_type_definition, variant_contract_class)
          end
        end

        def build_type_shape(type_definition, contract_class)
          type_shape = Object.new(contract_class, action_name: @shape.action_name)
          type_shape.copy_type_definition_params(type_definition, type_shape)
          type_shape
        end
      end
    end
  end
end
