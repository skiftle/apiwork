# frozen_string_literal: true

module Apiwork
  module Introspection
    class TypeSerializer
      def initialize(api_class)
        @api_class = api_class
      end

      def serialize_types
        return {} unless @api_class

        @api_class.type_system.types.each_pair.sort_by { |name, _| name.to_s }.each_with_object({}) do |(qualified_name, metadata), result|
          result[qualified_name] = serialize_type(qualified_name, metadata)
        end
      end

      def serialize_type(qualified_name, metadata)
        expanded_shape = metadata[:expanded_payload] ||= expand_payload(metadata)

        base = if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union
                 expanded_shape
               elsif expanded_shape.present?
                 { type: :object, shape: expanded_shape }
               else
                 { type: :object }
               end

        result = base.merge({
          description: resolve_type_description(qualified_name, metadata),
          example: resolve_type_example(metadata),
          format: metadata[:format]
        }.compact)

        result[:deprecated] = true if metadata[:deprecated]

        result
      end

      def serialize_enums
        return {} unless @api_class

        @api_class.type_system.enums.each_pair.sort_by { |name, _| name.to_s }.each_with_object({}) do |(qualified_name, metadata), result|
          result[qualified_name] = serialize_enum(qualified_name, metadata)
        end
      end

      def serialize_enum(qualified_name, metadata)
        result = {
          values: metadata[:values],
          description: resolve_enum_description(qualified_name, metadata),
          example: metadata[:example]
        }.compact

        result[:deprecated] = true if metadata[:deprecated]

        result
      end

      private

      def resolve_type_description(type_name, metadata)
        return metadata[:description] if metadata[:description]

        if metadata[:schema_class].respond_to?(:description)
          schema_description = metadata[:schema_class].description
          return schema_description if schema_description
        end

        @api_class.metadata.i18n_lookup(:types, type_name, :description)
      end

      def resolve_type_example(metadata)
        return metadata[:example] if metadata[:example]

        metadata[:schema_class]&.example
      end

      def resolve_enum_description(enum_name, metadata)
        return metadata[:description] if metadata[:description]

        @api_class.metadata.i18n_lookup(:enums, enum_name, :description)
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

        temp_definition = Apiwork::Contract::ParamDefinition.new(
          type: :body,
          contract_class: temp_contract
        )

        Array(definitions).each do |definition_block|
          temp_definition.instance_eval(&definition_block)
        end

        DefinitionSerializer.new(temp_definition).serialize
      end

      def create_temp_contract
        contract = Class.new(Apiwork::Contract::Base)
        contract.instance_variable_set(:@api_class, @api_class)
        contract
      end
    end
  end
end
