# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Type
        def initialize(api_class)
          @api_class = api_class
        end

        def types
          return {} unless @api_class

          @api_class.type_system.types.each_pair.sort_by { |name, _| name.to_s }.each_with_object({}) do |(qualified_name, metadata), result|
            result[qualified_name] = build_type(qualified_name, metadata)
          end
        end

        def enums
          return {} unless @api_class

          @api_class.type_system.enums.each_pair.sort_by { |name, _| name.to_s }.each_with_object({}) do |(qualified_name, metadata), result|
            result[qualified_name] = build_enum(qualified_name, metadata)
          end
        end

        def build_type(qualified_name, metadata)
          expanded_shape = metadata[:expanded_payload] || expand_payload(metadata)

          if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union
            {
              deprecated: metadata[:deprecated] == true,
              description: resolve_type_description(qualified_name, metadata),
              discriminator: expanded_shape[:discriminator],
              example: metadata[:example] || metadata[:schema_class]&.example,
              format: metadata[:format],
              shape: expanded_shape[:shape] || {},
              type: :union,
              variants: expanded_shape[:variants] || [],
            }
          else
            {
              deprecated: metadata[:deprecated] == true,
              description: resolve_type_description(qualified_name, metadata),
              discriminator: nil,
              example: metadata[:example] || metadata[:schema_class]&.example,
              format: metadata[:format],
              shape: expanded_shape || {},
              type: :object,
              variants: [],
            }
          end
        end

        def build_enum(qualified_name, metadata)
          {
            deprecated: metadata[:deprecated] == true,
            description: resolve_enum_description(qualified_name, metadata),
            example: metadata[:example],
            values: metadata[:values] || [],
          }
        end

        private

        def resolve_type_description(type_name, metadata)
          return metadata[:description] if metadata[:description]

          if metadata[:schema_class].respond_to?(:description)
            schema_description = metadata[:schema_class].description
            return schema_description if schema_description
          end

          result = @api_class.structure.i18n_lookup(:types, type_name, :description)
          return result if result

          I18n.t(:"apiwork.types.#{type_name}.description", default: nil)
        end

        def resolve_enum_description(enum_name, metadata)
          return metadata[:description] if metadata[:description]

          result = @api_class.structure.i18n_lookup(:enums, enum_name, :description)
          return result if result

          I18n.t(:"apiwork.enums.#{enum_name}.description", default: nil)
        end

        def expand_payload(metadata)
          definition_blocks = metadata[:definitions] || metadata[:definition]
          payload = metadata[:payload] || expand(definition_blocks, contract_class: metadata[:scope])

          payload = expand_union_variants(payload, metadata[:scope]) if payload.is_a?(Hash) && payload[:type] == :union

          payload
        end

        def expand_union_variants(payload, scope)
          return payload unless payload[:variants]

          expanded_variants = payload[:variants].map do |variant|
            expanded = if variant[:shape_block]
                         expanded_shape = expand(variant[:shape_block], contract_class: scope)
                         variant.except(:shape_block).merge(shape: expanded_shape.presence || {})
                       else
                         variant
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

          @api_class.type_system.types.key?(type_name) || @api_class.type_system.enums.key?(type_name)
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
          contract.instance_variable_set(:@api_class, @api_class)
          contract
        end
      end
    end
  end
end
