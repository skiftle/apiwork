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

          shape.params.each do |name, param_options|
            next unless transformed.key?(name)

            value = transformed[name]

            if param_options[:as]
              transformed[param_options[:as]] = transformed.delete(name)
              name = param_options[:as]
              value = transformed[name]
            end

            if param_options[:shape] && value.is_a?(Hash)
              transformed[name] = Transformer.new(param_options[:shape]).transform(value)
            elsif param_options[:shape] && value.is_a?(Array)
              transformed[name] = value.map do |item|
                item.is_a?(Hash) ? Transformer.new(param_options[:shape]).transform(item) : item
              end
            elsif param_options[:type] == :array && param_options[:of] && value.is_a?(Array)
              result = transform_custom_type_array(value, param_options)
              transformed[name] = result if result
            end
          end

          apply_sti_transforms(transformed)

          transformed
        end

        def apply_sti_transforms(params)
          shape.params.each do |name, param_options|
            if param_options[:store] && params.key?(name)
              params[name] = param_options[:store]
            elsif param_options[:transform] && params.key?(name)
              params[name] = param_options[:transform].call(params[name])
            end

            value = params[name]
            next unless value.is_a?(Hash)

            if param_options[:shape]
              Transformer.new(param_options[:shape]).apply_sti_transforms(value)
            elsif param_options[:union]
              apply_sti_transform_to_union(value, param_options[:union])
            elsif param_options[:type].is_a?(Symbol)
              apply_sti_transform_to_custom_type(value, param_options[:type])
            end
          end
        end

        private

        attr_reader :shape

        def apply_sti_transform_to_union(value, union)
          discriminator = union.discriminator
          return unless discriminator && value.key?(discriminator)

          tag = value[discriminator]
          variant = union.variants.find do |variant|
            variant[:tag].to_s == tag.to_s
          end
          return unless variant

          apply_sti_transform_to_custom_type(value, variant[:type])
        end

        def apply_sti_transform_to_custom_type(value, type_name)
          contract_class = shape.contract_class
          type_definition = contract_class.resolve_custom_type(type_name)

          if type_definition
            temp_shape = build_temp_shape(type_definition, contract_class)
            Transformer.new(temp_shape).apply_sti_transforms(value)
          else
            apply_sti_transform_to_registered_union(value, type_name)
          end
        end

        def apply_sti_transform_to_registered_union(value, type_name)
          contract_class = shape.contract_class
          api_class = contract_class.api_class

          scoped_name = api_class.scoped_type_name(contract_class, type_name)
          type_definition = api_class.type_registry[scoped_name] || api_class.type_registry[type_name]
          return unless type_definition

          payload = type_definition.payload
          return unless payload && payload[:type] == :union

          discriminator = payload[:discriminator]
          return unless discriminator && value.key?(discriminator)

          tag = value[discriminator]
          variant = payload[:variants]&.find { |variant| variant[:tag].to_s == tag.to_s }
          return unless variant

          apply_sti_transform_to_custom_type(value, variant[:type])
        end

        def transform_custom_type_array(value, param_options)
          custom_type_shape = resolve_custom_type_shape(param_options[:of])
          return nil unless custom_type_shape

          value.map do |item|
            item.is_a?(Hash) ? Transformer.new(custom_type_shape).transform(item) : item
          end
        end

        def resolve_custom_type_shape(type_name)
          contract_class = shape.contract_class
          type_definition = contract_class.resolve_custom_type(type_name)
          return nil unless type_definition

          scope_contract_class = type_definition.scope || contract_class

          if type_definition.object?
            build_temp_shape(type_definition, scope_contract_class)
          elsif type_definition.union?
            first_variant = type_definition.variants.first
            return nil unless first_variant

            variant_type_definition = scope_contract_class.resolve_custom_type(first_variant[:type])
            return nil unless variant_type_definition&.object?

            variant_contract_class = variant_type_definition.scope || scope_contract_class
            build_temp_shape(variant_type_definition, variant_contract_class)
          end
        end

        def build_temp_shape(type_definition, contract_class)
          temp_shape = Object.new(contract_class, action_name: shape.action_name)
          temp_shape.copy_type_definition_params(type_definition, temp_shape)
          temp_shape
        end
      end
    end
  end
end
