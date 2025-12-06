# frozen_string_literal: true

module Apiwork
  module Introspection
    class TypeSerializer
      def initialize(api_class)
        @api_class = api_class
      end

      def serialize_types
        result = {}

        return result unless @api_class

        type_storage = @api_class.type_system.types
        type_storage.each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
          expanded_shape = metadata[:expanded_payload] ||= expand_payload(metadata)
          description = resolve_type_description(qualified_name, metadata)
          example = resolve_type_example(metadata)

          base = if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union
                   expanded_shape
                 else
                   { type: :object, shape: expanded_shape }
                 end

          base[:description] = description if description
          base[:example] = example if example
          base[:format] = metadata[:format] if metadata[:format]
          base[:deprecated] = true if metadata[:deprecated]

          result[qualified_name] = base
        end

        result
      end

      def serialize_enums
        result = {}

        return result unless @api_class

        enum_storage = @api_class.type_system.enums
        enum_storage.each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
          enum_data = { values: metadata[:values] }
          description = resolve_enum_description(qualified_name, metadata)
          enum_data[:description] = description if description
          enum_data[:example] = metadata[:example] if metadata[:example]
          enum_data[:deprecated] = true if metadata[:deprecated]
          result[qualified_name] = enum_data
        end

        result
      end

      private

      def resolve_type_description(type_name, metadata)
        return metadata[:description] if metadata[:description]

        if metadata[:schema_class].respond_to?(:description)
          schema_description = metadata[:schema_class].description
          return schema_description if schema_description
        end

        i18n_type_description(type_name)
      end

      def resolve_type_example(metadata)
        return metadata[:example] if metadata[:example]

        metadata[:schema_class]&.example
      end

      def i18n_type_description(type_name)
        @api_class.metadata.i18n_lookup(:types, type_name, :description)
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
            variant[:shape] = expanded_shape
          end
          variant
        end
      end

      def expand(definitions, contract_class: nil)
        return nil unless definitions

        temp_contract = contract_class || create_temp_contract

        temp_definition = Apiwork::Contract::Definition.new(
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
