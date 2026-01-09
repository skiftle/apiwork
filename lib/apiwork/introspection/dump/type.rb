# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Type
        def initialize(api_class)
          @api_class = api_class
        end

        def to_h
          {
            enums: enums,
            types: types,
          }
        end

        def types
          @api_class.type_registry.each_pair.sort_by { |name, _definition| name.to_s }.each_with_object({}) do |(qualified_name, definition), result|
            result[qualified_name] = build_type(qualified_name, definition)
          end
        end

        def enums
          @api_class.enum_registry.each_pair.sort_by { |name, _definition| name.to_s }.each_with_object({}) do |(qualified_name, definition), result|
            result[qualified_name] = build_enum(qualified_name, definition)
          end
        end

        def build_type(qualified_name, definition)
          expanded_shape = definition.payload || expand_payload(definition)
          expanded_shape = expand_union_variants(expanded_shape, definition.scope) if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union

          if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union
            {
              deprecated: definition.deprecated?,
              description: resolve_type_description(qualified_name, definition),
              discriminator: expanded_shape[:discriminator],
              example: definition.example || definition.schema_class&.example,
              format: definition.format,
              shape: expanded_shape[:shape] || {},
              type: :union,
              variants: expanded_shape[:variants] || [],
            }
          else
            {
              deprecated: definition.deprecated?,
              description: resolve_type_description(qualified_name, definition),
              discriminator: nil,
              example: definition.example || definition.schema_class&.example,
              format: definition.format,
              shape: expanded_shape || {},
              type: :object,
              variants: [],
            }
          end
        end

        def build_enum(qualified_name, definition)
          {
            deprecated: definition.deprecated?,
            description: resolve_enum_description(qualified_name, definition),
            example: definition.example,
            values: definition.values || [],
          }
        end

        private

        def resolve_type_description(type_name, definition)
          return definition.description if definition.description

          if definition.schema_class.respond_to?(:description)
            schema_description = definition.schema_class.description
            return schema_description if schema_description
          end

          result = @api_class.structure.i18n_lookup(:types, type_name, :description)
          return result if result

          I18n.t(:"apiwork.types.#{type_name}.description", default: nil)
        end

        def resolve_enum_description(enum_name, definition)
          return definition.description if definition.description

          result = @api_class.structure.i18n_lookup(:enums, enum_name, :description)
          return result if result

          I18n.t(:"apiwork.enums.#{enum_name}.description", default: nil)
        end

        def expand_payload(definition)
          definition_blocks = definition.all_definitions
          expand(definition_blocks, contract_class: definition.scope)
        end

        def expand_union_variants(payload, scope)
          return payload unless payload[:variants]

          expanded_variants = payload[:variants].map do |variant|
            expanded = if variant[:shape_block]
                         expanded_shape = expand(variant[:shape_block], contract_class: scope)
                         variant.except(:shape_block).merge(shape: expanded_shape.presence || {})
                       else
                         variant.merge(shape: variant[:shape] || {})
                       end

            transform_variant_refs(expanded)
          end

          payload.merge(variants: expanded_variants)
        end

        def transform_variant_refs(variant)
          result = variant.dup

          if variant[:type] && registered_type_or_enum?(variant[:type])
            result[:ref] = variant[:type]
            result[:type] = :ref
          else
            result[:ref] ||= nil
          end

          if variant[:of] && registered_type_or_enum?(variant[:of])
            result[:of] = { ref: variant[:of], shape: {}, type: :ref }
          elsif variant[:of]
            result[:of] = { ref: nil, type: variant[:of] }
          end

          result
        end

        def registered_type_or_enum?(type_name)
          return false unless type_name.is_a?(Symbol)
          return false unless @api_class

          @api_class.type_registry.key?(type_name) || @api_class.enum_registry.key?(type_name)
        end

        def expand(definitions, contract_class: nil)
          return nil unless definitions

          temp_contract = contract_class || create_temp_contract

          temp_param = Apiwork::Contract::Param.new(temp_contract)

          Array(definitions).each do |definition_block|
            temp_param.instance_eval(&definition_block)
          end

          Param.new(temp_param).to_h
        end

        def create_temp_contract
          contract = Class.new(Apiwork::Contract::Base)
          contract.api_class = @api_class
          contract
        end
      end
    end
  end
end
