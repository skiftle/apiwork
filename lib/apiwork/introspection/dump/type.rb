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
          expanded_shape = metadata[:expanded_payload] ||= expand_payload(metadata)

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

          expand_union_variants(payload, metadata[:scope]) if payload.is_a?(Hash) && payload[:type] == :union

          payload
        end

        def expand_union_variants(payload, scope)
          return unless payload[:variants]

          payload[:variants] = payload[:variants].map do |variant|
            if variant[:shape_block]
              expanded_shape = expand(variant[:shape_block], contract_class: scope)
              variant = variant.dup
              variant.delete(:shape_block)
              variant[:shape] = expanded_shape if expanded_shape.present?
            end
            variant
          end
        end

        def expand(definitions, contract_class: nil)
          return nil unless definitions

          temp_contract = contract_class || create_temp_contract

          temp_param_definition = Apiwork::Contract::ParamDefinition.new(temp_contract)

          Array(definitions).each do |definition_block|
            temp_param_definition.instance_eval(&definition_block)
          end

          ParamDefinition.new(temp_param_definition).to_h
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
